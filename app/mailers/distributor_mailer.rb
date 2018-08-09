class DistributorMailer < ActionMailer::Base
  default from: "support@hairillusion.com"

  def new_distributor_admin_notification(distributor)
    @distributor = distributor
    mail(to: [ 'support@hairillusion.com'], subject: 'Hair Illusion new Wholesaler singedup.')
  end

  def approved(distributor, password)
    @distributor = distributor
    @password = password
    mail(to: distributor.email, subject: 'Hair Illusion Wholesaler Request Approved')
  end
  
  def new_distributor_notification(distributor)
    @distributor = distributor
    mail(to: @distributor.email, subject: 'Your Hair Illusion Wholesaler Account Created')
  end
   
  def notify_price_change(distributor)
    @distributor = distributor 
    @price_list = DistributorProductPrice.where(:distributor_id=>distributor.id)
    mail(to: @distributor.email, subject: 'Your Hair Illusion Product Purchase Link')
  end
  
end
