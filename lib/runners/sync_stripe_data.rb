module Runners
  class SyncStripeData
    def self.perform
      Stripe::Charge.all(count: 100).each do |stripe_charge|
        next if stripe_charge.customer.nil?

        stripe_customer = Stripe::Customer.retrieve(stripe_charge.customer)

        next if stripe_customer[:deleted]

        customer = Customer.where(stripe_id: stripe_customer.id).first_or_create!(
          stripe_id: stripe_customer.id,
          email: stripe_customer.email,
          first_name: stripe_customer.metadata[:first_name],
          last_name: stripe_customer.metadata[:last_name],
          address1: stripe_customer.metadata[:address1],
          address2: stripe_customer.metadata[:address2],
          city: stripe_customer.metadata[:city],
          state: stripe_customer.metadata[:state],
          zip: stripe_customer.metadata[:zip]
        )

        product_code = /.*\((\d{4})\)$/.match(stripe_customer.metadata[:color]).captures[0]

        customer.orders.create!(
          stripe_id: stripe_charge.id,
          order_items_attributes: [{
              product: Product.where(product_code: product_code).first,
              quantity: 1
            }
          ],
        )
      end
    end
  end
end
