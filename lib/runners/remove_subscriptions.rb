module Runners
  class RemoveSubscriptions
    def self.perform
      Stripe::Customer.all(count: 100).each do |customer|
        customer.subscriptions.each do |s|
          subscription = customer.subscriptions.retrieve(s.id).delete()
        end
      end
    end
  end
end
