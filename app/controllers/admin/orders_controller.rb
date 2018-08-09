class Admin::OrdersController < Admin::ApplicationController
  respond_to :html, except: [:shipping]
  respond_to :js, only: [:index]
  
  def distributor_orders
    distributor_ids = Distributor.all.collect(&:id)
 
    @orders = Order.where("orderer_id in (?) and orderer_type='Distributor'",distributor_ids).order("DATE(created_at) DESC").page(params[:page]).per_page(10) 
  end
  
  def index
    if params[:customer_id]
      @orderer = Customer.find(params[:customer_id])
    elsif params[:distributor_id]
      @orderer = Distributor.find(params[:distributor_id])
    end

    respond_to do |format|
      format.html {}
      format.js do
        if @orderer.present?
          @orders = @orderer.orders
        else
          @orders = Order.includes(:orderer)
        end

        grid_table_for(@orders, index_params)
      end
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  def new
    if params[:distributor_id]
      @distributor = Distributor.find(params[:distributor_id])
      @order = @distributor.orders.build
      @credit_card = CreditCard.new

      Product.all.each do |p|
        @order.order_items<< OrderItem.new(product: p, quantity: 0)
      end
    elsif params[:customer_id]
      @customer = Customer.find(params[:customer_id])
      @order = @customer.orders.build
      @order_item = @order.order_items.build
      @credit_card = CreditCard.new
    else
      @customer = Customer.new
      @order = @customer.orders.build
      @order_item = @order.order_items.build
      @credit_card = CreditCard.new
    end
  end

  def create
    if params[:distributor_id].present?
      @orderer = Distributor.find(params[:distributor_id])
      orderer_valid = true
    elsif params[:customer_id].present?
      @orderer = Customer.find(params[:customer_id])
      orderer_valid = true
    else
      @orderer = Customer.new(customer_params)
      orderer_valid = @orderer.valid?
    end

    @order = @orderer.orders.build(order_params)
    @order.host = request.host
    @credit_card = CreditCard.new(cc_params)

    order_valid = @order.valid?
    credit_card_valid = @credit_card.valid?

    if orderer_valid && order_valid && credit_card_valid
      begin
        if @orderer.stripe_id.blank?
          stripe_customer = Stripe::Customer.create(
            email: @orderer.email
          )

          @orderer.stripe_id = stripe_customer.id
        end

        total_price = @order.total(@orderer.try(:price))

        charge = Stripe::Charge.create(
          amount: total_price,
          description: @order.description,
          currency: 'usd',
          card: cc_params
        )

        @order.stripe_id = charge.id 
        @orderer.save!
        @order.save! 
        OrderMailer.receipt(@order, total_price).deliver

        flash[:notice] = "Thanks for your order"
        redirect_to params[:distributor_id].present? ? admin_distributor_path(@orderer) : admin_customer_path(@orderer)
      rescue Stripe::CardError => e
        # Since it's a decline, Stripe::CardError will be caught
        body = e.json_body
        err  = body[:error]

        puts "Status is: #{e.http_status}"
        puts "Type is: #{err[:type]}"
        puts "Code is: #{err[:code]}"
        # param is '' in this case
        puts "Param is: #{err[:param]}"
        puts "Message is: #{err[:message]}"

        flash[:alert] = err[:message]

        render admin_order_path(@order)
      rescue => e
        # Something else happened, completely unrelated to Stripe
        flash[:alert] = e.message
        render admin_order_path(@order)
      end
    else
      render admin_order_path(@order)
    end
  end

  def edit
    @order = Order.find(params[:id])
    if @order.orderer_type == Distributor.name
      @distributor = @order.orderer
    elsif @order.orderer_type == Customer.name
      @customer = @order.orderer
      @order_item = @order.order_items.build
    end

    @credit_card = CreditCard.new
  end

  def update
    @order = Order.find(params[:id])

    if @order.update_attributes(order_params)
      redirect_to admin_order_path(@order)
    else
      render :edit
    end
  end

  def refund
    @order = Order.find(params[:id])

    begin
      @order.stripe_charge.refund
      @order.update_attribute(:refunded_at, Time.now)

      redirect_to(admin_order_path(@order))
    rescue => e
      # Something else happened, completely unrelated to Stripe
      flash[:alert] = e.message
      render admin_order_path(@order)
    end
  end
  
  def pull_details_from_shopify
    shop_url = "https://a98b179d72117d149e44ae83796e4c64:b62b5da657f75898e1d45eb6a6e0e247@hair-illusion-llc.myshopify.com/admin"
    ShopifyAPI::Base.site = shop_url 
    
    customers = ShopifyAPI::Customer.all  
    i = 0
    customers.each do |c|  
      email = c.email
      db_customer = Customer.find_by_email(email) 
       
      if db_customer.nil?
        address = c.default_address
        i = i+1
        customer = Customer.new(:email=>email, :first_name=>c.first_name, :last_name=>c.last_name, :address1 => address.address1,:address2 => address.address2, :created_at=>c.created_at,
        :city=> address.city, :country =>address.country_code, :state=>address.province, :zip=>address.zip, :stripe_id=>"shopify"+Time.now.to_i.to_s+i.to_s, :shopify_customer_id=>c.id)
        customer.save(validate: false)    
      else 
        db_customer.shopify_customer_id = c.id
        db_customer.save(validate: false)
      end
    end
    
    orders = ShopifyAPI::Order.all 
    orders.each do |o|   
      order = Order.find_by_shopify_order_id(o.id)
      if order.nil? 
        customer = Customer.find_by_shopify_customer_id(o.customer.id) 
        customer_id = customer.id 
        
        order = Order.new(:orderer_id=>customer_id, :orderer_type=>'Customer', :shopify_order_id=>o.id, :created_at=>o.processed_at)
        order.save
        
        host = ""
        landing_site = o.landing_site
         
        if landing_site.include?('hairillusion.net')
          host = "hairillusion.net" 
          distributor = DomainDistributor.where(:domain=>"hairillusion.net").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end
        elsif landing_site.include?('buyhairillusion.com') 
          host = "buyhairillusion.com" 
          distributor = DomainDistributor.where(:domain=>"buyhairillusion.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end
        elsif landing_site.include?('gethairillusion.com') 
          host = 'gethairillusion.com'
          distributor = DomainDistributor.where(:domain=>"gethairillusion.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end 
        elsif landing_site.include?('hairillusion.com') 
          host = 'hairillusion.com'
          distributor = DomainDistributor.where(:domain=>"hairillusion.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end 
        else  
          DomainDistributor.all.each do |d| 
            if landing_site.include?(d.domain)  
              distributor_order = DistributorOrder.new(:distributor_id=>d.id, :order_id=>order.id, :created_at=>order.created_at)
              distributor_order.save
              host = "#{d.domain}"  
              OrderMailer.send_order_email(distributor_order.distributor_id, distributor_order.order_id).deliver
            end 
          end
        end  
        
        order.update_attribute(:host,host) 
        o.line_items.each do |item| 
          product = Product.where("lower(description) = ?", item.variant_title.downcase).first  
          product_id = nil 
          product_id = product.id unless product.nil?   
          price = item.price.to_f*100 
          order_item = OrderItem.new(:quantity=>item.quantity, :price=>price, :order_id=>order.id,:product_id=>product_id )  
          order_item.save!   
        end 
      end
    end
  end

  private
  def index_params
    params.permit [].concat(Order.grid_table_strong_params)
  end

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :email, :address1, :address2, :city, :state, :zip, :country)
  end

  def order_params
    params.require(:order).permit(:orderer_id, order_items_attributes: [:product_id, :quantity])
  end

  def cc_params
    params.require(:credit_card).permit(:name, :number, :cvc, :exp_month, :exp_year)
  end
end
