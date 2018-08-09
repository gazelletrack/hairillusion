class CustomerCard < ActiveRecord::Base  
  
  attr_encrypted_options.merge!(:encode => true)
    attr_encrypted :card_number, :key => 'thisihaisdyad,asncak@&&$%^$hkhsd'
    attr_encrypted :exp_year, :key => 'thisihaisdyad,asncak@&&$%^$hkhsd'
    attr_encrypted :exp_month, :key => 'thisihaisdyad,asncak@&&$%^$hkhsd'
    attr_encrypted :ccv, :key => 'thisihaisdyad,asncak@&&$%^$hkhsd'
  
  def load
    # loads the stored data
  end
  
end
