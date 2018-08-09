class OrderMailer < ActionMailer::Base
  default from: "support@hairillusion.com"

  def receipt(order, total_price,shipping_price)
    @order = order
    @total_price = total_price 
    if shipping_price
       @shipping_cost = shipping_price
    else
       @shipping_cost = order.shipping_cost
    end
    mail(to: @order.orderer.email, subject: 'Hair Illusion Order')
  end
  
  def reset_email(distributor_id)
    @d = Distributor.find distributor_id
    @password = (0...8).map { (65 + rand(26)).chr }.join.downcase
    @d.password = @password
    @d.password_confirmation = @password
    @d.require_password_reset = true  
    @d.save!
    mail(to: @d.email, subject: 'Hairillusion password reset request')    
  end

  def customer_reset_email(distributor_id)
    @d = Customer.find distributor_id
    if @d.password.blank?
      @d.password = "hairillusion"
      @password = "hairillusion" 
      @d.save!
    else
       @password = @d.password
    end 
    mail(to: @d.email, subject: 'Hairillusion password reset request')    
  end
   
  def charged_notification(customer_id, price)
    @customer = Customer.find customer_id
    @price = price
    mail(to: ['freelancer8429@gmail.com','support@hairillusion.com'], subject: "Charged to old hair club customer") 
  end
  
  def send_enquiry(params)
    @params = params
    logger.info params.inspect
    
    mail(to: ['freelancer8429@gmail.com','support@hairillusion.com'], subject: "New enquiry received")  
  end
  
  def error_generated(errors,order_id)
    @errors = errors
    order = Order.find order_id
    mail(to: ['freelancer8429@gmail.com'], subject: '#{errors}')    
  end
  
  def order_receipt(order_id) 
    @order = Order.find order_id 
    
    if @order
      @total_price = @order.total_price
      @shipping_cost = @order.get_shipping_cost
    end 
    mail(to: @order.orderer.email, subject: 'Your Hair Illusion Order Details') 
  end
  
  def monthly_order_receipt(order_id) 
    @order = Order.find order_id
    if @order
      @total_price = @order.total_price
      @shipping_cost = @order.get_shipping_cost
    end 
    email_id = @order.orderer.email
    email_id = "freelancer8429@gmail.com" if email_id.blank?
    mail(to: email_id , subject: 'Your Montly Hair Illusion product Dispatched') 
  end
  
  def card_updated_notification(customer_id)
    @customer = Customer.find customer_id
    mail(to: 'support@hairillusion.com,freelancer8429@gmail.com', subject: "One of the customer updated his card") 
 end
  
  def admin_notification(order_id) 
    @order = Order.find order_id
    if @order
      @total_price = @order.total_price
      @shipping_cost = @order.get_shipping_cost
    end 
    mail(to: ['freelancer8429@gmail.com','support@hairillusion.com'], subject: "New order generated from #{@order.host}") 
  end

  def monthly_order_notification(order_id) 
    @order = Order.find order_id
    if @order
      @total_price = @order.total_price
      @shipping_cost = @order.get_shipping_cost
    end 
    mail(to: ['freelancer8429@gmail.com','support@hairillusion.com'], subject: "Monthly Automated order generated") 
  end
    
  def send_notification(order, total_price, shipping_price) 
    @order = order
    @total_price = total_price
    if shipping_price
       @shipping_cost = shipping_price
    else
       @shipping_cost = order.shipping_cost
    end
   
    mail(to: ['freelancer8429@gmail.com'], subject: 'Hair Illusion Distributor Order recieved')
  end

  def shipped(order)
    @order = order
    mail(to: @order.orderer.email, subject: 'Hair Illusion Order Shipped')
  end
   
  def send_order_email(distributor_id, order_id)  
    @order = Order.find order_id
    @distributor = DomainDistributor.where(:id=>distributor_id).first
    emails = "#{@distributor.email},freelancer8429@gmail.com" 
    mail(to: emails, subject: "New Order created from your domain-#{@distributor.domain}") 
  end
  
  def send_forum_email(forum_details) 
    @forum_details = forum_details 
    mail(to: ['freelancer8429@gmail.com','support@buyhairillusion.com'], subject: "New forum posted", from:"forum posted")
  end 
  
  def send_shipwire_error(error,order_id) 
    @error = error
    @order_id = order_id
    mail(to: "freelancer8429@gmail.com", subject: "Shipwire error")    
  end
  
  
  def admin_cancel_notification(order_id) 
    @order = Order.find order_id
    @orderer = @order.orderer
    mail(to: ["freelancer8429@gmail.com","support@hairillusion.com"], subject: "Order was cancelled") 
  end

  def order_cancel_confirmation(order_id) 
    @order = Order.find order_id 
    mail(to: @orderer.email, subject: "Order was cancelled") 
  end
  
  def send_signup_notification(customer_id)
    @customer = Customer.find customer_id 
    mail(to: @customer.email, cc:"freelancer8429@gmail.com", subject: "You have successfully registered to hairillusion official website") 
  end 
    
end