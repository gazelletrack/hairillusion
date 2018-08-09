xml.instruct!
xml.tag!('Print', xmlns: 'http://stamps.com/xml/namespace/2009/8/Client/BatchProcessingV1') do
  @shipment.orders.each do |o|
    o.prepare_for_shipping.each do |order|
      xml.tag!('Item') do
        xml.tag!('OrderID', order.order_id)
        xml.tag!('OrderDate', order.created_at.strftime('%Y-%m-%d'))
        xml.tag!('Services')
        xml.tag!('MailClass', order.mail_class)
        xml.tag!('Mailpiece', order.mail_piece)
        xml.tag!('WeightOz', order.total_weight)
        xml.tag!('Recipient') do
          orderer = order.orderer

          xml.tag!('AddressFields') do
            xml.tag!('FirstName', orderer.first_name)
            xml.tag!('LastName', orderer.last_name)
            xml.tag!('MultilineAddress') do
              xml.tag!('Line', orderer.company_name) if orderer.try(:company_name).present?
              xml.tag!('Line', orderer.address1)
              xml.tag!('Line', orderer.address2) if orderer.address2.present?
            end
            xml.tag!('City', orderer.city)
            xml.tag!('State_Region_Province', orderer.state)
            xml.tag!('ZIP', orderer.zip)
            xml.tag!('Country', get_country_name(orderer.try(:country),true))
            xml.tag!('OrderedEmailAddresses') do
              xml.tag!('Address', orderer.email)
            end
          end
        end

        xml.tag!('OrderContents') do
          order.order_items.each do |oi|
            xml.tag!('Item') do
              xml.tag!('ExternalID', oi.product.product_code)
              xml.tag!('Name', oi.product.description)
              xml.tag!('Price', oi.price / 100.0)
              xml.tag!('Quantity', oi.quantity)
              xml.tag!('WeightOz', oi.weight)
            end
          end
        end
      end
    end
  end
end
