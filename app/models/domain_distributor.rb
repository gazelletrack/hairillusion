class DomainDistributor < ActiveRecord::Base
 
    validates :name, :domain, presence: true 
    has_many :distributor_orders, foreign_key: "distributor_id"   
    validates :domain, uniqueness: true  
  
  def self.update_orders
    order_ids = Order.where(:host=>"tryhairillusion.com").collect(&:id) 
    new_d= DomainDistributor.where("domain='tryhairillusion.com'").first
    new_id = new_d.id 
    distributor_orders = DistributorOrder.where("order_id in (?)",order_ids)
    distributor_orders.each do |s| 
      s.update_attribute(:distributor_id,new_id)
    end
  end 
 
  def self.get_orders  
    logger.info "**************************---here starts updated rake****************************"
    shop_url = "https://a98b179d72117d149e44ae83796e4c64:b62b5da657f75898e1d45eb6a6e0e247@hair-illusion-llc.myshopify.com/admin"
    ShopifyAPI::Base.site = shop_url  
    total_pages = 15
    customers_list = []
    (1..15).each do |page| 
      customers = ShopifyAPI::Customer.all( params: {limit: 250, page: page, status: 'any' })  
       customers.each do |c|  
         customers_list << c
       end
    end 
    i = 0
    (1..15).each do |page| 

    customers_list.each do |c|  
      email = c.email
      db_customer = Customer.find_by_email(email) 
       address = c.default_address 
      if db_customer.nil? 
        i = i+1
        logger.info address.inspect
        state = "not mentioned"
        if address.province
          state = address.province 
          state = "not mentioned" if state.nil?
        end 
        
        zip_value = address.zip
        zip_value = "not mentioned" if zip_value.blank?
        customer = Customer.new(:email=>email, :first_name=>c.first_name, :last_name=>c.last_name, :address1 => address.address1,:address2 => address.address2, :created_at=>c.created_at,
        :city=> address.city, :country =>address.country_code, :state=>state, :zip=>zip_value, :stripe_id=>"shopify"+Time.now.to_i.to_s+i.to_s, :shopify_customer_id=>c.id)
        
        customer.save(validate=> false)    
      else   
        state = "not mentioned"
        if address.province
          state = address.province 
          state = "not mentioned" if state.nil?
        end 
        address = c.default_address
        db_customer.shopify_customer_id = c.id 
        db_customer.first_name = c.first_name
        db_customer.last_name=c.last_name
        db_customer.address1=address.address1
        db_customer.address2=address.address2
        db_customer.city=address.city
        db_customer.country =address.country_code
        db_customer.state =state
        if address.zip && !address.zip.blank?
          db_customer.zip =address.zip  
        else
          db_customer.zip = "not mentioned"
        end
        
        db_customer.save(validate: false) 
        customer = db_customer
      end
    end 
    
    orders = ShopifyAPI::Order.all( params: {limit: 250, page: page, status: 'any' })   
    
    orders.each do |o|   
      distributor_order = nil 
      order = Order.find_by_shopify_order_id(o.id)
      if order.nil? 
        customer = Customer.find_by_shopify_customer_id(o.customer.id) 
        customer_id = customer.id 
        
        order = Order.new(:orderer_id=>customer_id, :orderer_type=>'Customer', :shopify_order_id=>o.id, :created_at=>o.processed_at)
        order.save
        
        host = ""
        landing_site = o.landing_site
        landing_site = "" if landing_site.nil?
        
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
        elsif landing_site.include?('facebook.com') 
          host = 'facebook.com'
          distributor = DomainDistributor.where(:domain=>"facebook.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end           
        elsif (landing_site.include?('hairillusion.com') && !landing_site.include?('tryhairillusion.com'))
          host = 'hairillusion.com'
          distributor = DomainDistributor.where(:domain=>"hairillusion.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end 
        elsif (landing_site.include?('hairillusionllc.com'))
          host = 'hairillusionllc.com'
          distributor = DomainDistributor.where(:domain=>"hairillusionllc.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end 
        elsif (landing_site.include?('hairisthere.com'))
          host = 'hairisthere.com'
          distributor = DomainDistributor.where(:domain=>"hairisthere.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end 
        elsif (landing_site.include?('hairillusionmagic.com'))
          host = 'hairillusionmagic.com'
          distributor = DomainDistributor.where(:domain=>"hairillusionmagic.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end 
        elsif (landing_site.include?('tryhairillusion.com'))
          host = 'tryhairillusion.com'
          distributor = DomainDistributor.where(:domain=>"tryhairillusion.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end
        elsif (landing_site.include?('hairillusion4you.com'))
          host = 'hairillusion4you.com'
          distributor = DomainDistributor.where(:domain=>"hairillusion4you.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end
        elsif (landing_site.include?('hairillusionmagic.com'))
          host = 'hairillusionmagic.com'
          distributor = DomainDistributor.where(:domain=>"hairillusionmagic.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end
        else  
          DomainDistributor.all.each do |d| 
            if landing_site.include?(d.domain) && d.domain != 'hairillusion.com'
              distributor_order = DistributorOrder.new(:distributor_id=>d.id, :order_id=>order.id, :created_at=>order.created_at)
              distributor_order.save
              host = "#{d.domain}"   
            end  
          end
          #if order has blank referer
          if distributor_order.nil? 
            distributor = DomainDistributor.where(:domain=>"hairillusion.net").first
            if distributor
              distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
              distributor_order.save
              host = "hairillusion.net"   
            end 
          end 
        end   
        
        order.update_attribute(:host,host)  
        o.line_items.each do |item| 
          if item.title == "Hair Illusion Fiber Hold Spray"
            product = Product.where("description = ?", "Hair Illusion Fiber Hold Spray").first  
          else 
            product = Product.where("sku = ?", item.sku).first  
          end 
          product_id = nil 
          product_id = product.id unless product.nil?   
          price = item.price.to_f*100 
          order_item = OrderItem.new(:quantity=>item.quantity, :price=>price, :order_id=>order.id,:product_id=>product_id )  
          order_item.save!   
        end     
        OrderMailer.send_order_email(distributor_order.distributor_id, distributor_order.order_id).deliver!
        
      end 
      end 
    end 
  end
    
end
