class Forum < ActiveRecord::Base
  
  validates :content,:name,:state,:country,:address, presence: true 
end