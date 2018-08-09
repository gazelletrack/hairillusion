 
 every 1.hour do
   #runner "DomainDistributor.get_orders"
 end 
every 10.minutes do
  rake "hair:shipwire_orders"
end