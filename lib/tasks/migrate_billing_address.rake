namespace :hair do

  task :migrate_current_address=> :environment do 
    customers = Customer.all
    customers.each do |c|
      c.billing_first_name = c.first_name if(c.billing_first_name.blank?)
      c.billing_last_name = c.last_name if(c.billing_last_name.blank?)
      c.billing_address1 = c.address1 if(c.billing_address1.blank?) 
      c.billing_address2 = c.address2 if(c.billing_address2.blank?)  
      c.billing_city = c.city if(c.billing_city.blank?) 
      c.billing_state = c.state if(c.billing_state.blank?) 
      c.country = "US" if c.country.blank?
      c.billing_country = c.country if(c.billing_country.blank?)  
      c.billing_zip = c.zip if(c.billing_zip.blank?)   
      c.save(:validate=>false)
    end
  end 
end