namespace :hair do

  task :add_country_price => :environment do 
    
     ISO3166::Country.all.each do |country| 
      if country.alpha2 != "US" 
        if country.alpha2 == "CA"
          country_price = CountryPrice.where(:country_code=>country.alpha2, :country=>country.name).first
          puts country_price.inspect
          unless country_price
            CountryPrice.create(:country_code=>country.alpha2, :country=>country.name, :price=>11.25)
          end
        else
          country_price = CountryPrice.where(:country_code=>country.alpha2, :country=>country.name).first
          unless country_price
            CountryPrice.create(:country_code=>country.alpha2, :country=>country.name, :price=>16.25)
          end
        end 
     
      end 
    end 
    
  end 

end