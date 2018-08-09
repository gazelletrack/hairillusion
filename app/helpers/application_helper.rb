module ApplicationHelper
  def control_group(object, method, params = {}, &block)
    hide_label = params[:hide_label] || false
    label_text = params[:label] || nil

    content_class = "form-group"
    error_content = ''

    if object.errors.include?(method)
      content_class += " has-error"
      error_content = content_tag(:span, object.errors[method][0], :class => 'help-block')
    end unless object.nil?

    content = ''
    content += label(object.class.to_s.downcase, method, label_text, :class => 'col-md-4 control-label') unless hide_label
    content += content_tag(:div, content_tag(:div, capture(&block), :class => 'col-sm-6') + error_content, :class => "controls row")

    content_tag(:div, raw(content), :class => content_class)
  end

  def icon_text(text, icon)
    output = content_tag(:i, nil, :class => icon)
    output += " #{text}" unless text.nil?

    raw output
  end

  ALERT_TYPES = [:danger, :info, :success, :warning]

  def flash_message
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = :success if type == :notice
      type = :danger  if type == :alert
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|

        text = content_tag(:div, content_tag(:div, content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                           msg.html_safe, :class => "alert alert-#{type} fade in"), class: 'col-md-12'), class: 'row')
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end

  def color_options_for_select(selected = nil)
    options = OrderItem::COLOR.collect { |key, value| [key.to_s.titleize, value] }
    options.unshift(['Select Your Color', nil])

    options_for_select(options, selected)
  end

  def us_state_options_for_select(selected = nil)
    options_for_select([
      [nil, nil],
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Washington DC', 'DC'],
      ['Delaware', 'DE'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ], selected)
  end
  
  def get_country_name(country_id, from_view)
    return "" if country_id.nil?
    country = Carmen::Country.coded(country_id)
    return "" if country.nil?
    country_name = country.name
    country_name = "United Kingdom Great Britain" if country_name == "United Kingdom"
    return "#{country_name}" if from_view == true
    return " , #{country_name}"
  end
  
  def get_commission(dist_orders)
    begin
    price = 0
    distributor_id = 0
    dist_orders.each do |order|
      price = price + order.order.total_commission_price 
    end
    
    if dist_orders.size > 0
      distributor_id = dist_orders.first.distributor_id
      distributor = DomainDistributor.find distributor_id
      percent = distributor.percentage
      price = price * (percent/100.00)
    end 
    return price 
    rescue 
      return 0 
    end
  end
  
  def get_total_sales(dist_orders)
    begin
    price = 0
    distributor_id = 0
    dist_orders.each do |order|  
      price = price + order.order.total_price 
    end 
    return price 
    rescue 
      return 0 
    end
  end
  
  def get_state_name(country_id,state_id)
    @country = Carmen::Country.coded(country_id)
    @subregion = @country.subregions.coded(state_id)
    return @subregion.name
  end
  
  def colours_list
    return [['Black 38G','2185852801'],['Black 18G','20329958337'],['Jet Black 38G','2185852737'],['Jet Black 18G','20329814529'],['Dark Brown 38G','2185852929'],['Dark Brown 18G','20329958465'],['Brown 38G','2185853057'],['Brown 18G','20329958401'],['Light Brown 38G','2185853185'],['Light Brown 18G','20329958529'],['Auburn 38G','2185853249'],['Auburn 18G','20329958593'],['Blonde 38G','2185853377'],['Blonde 18G','20329958657'],['Light Blonde 38G','2185853441'],['Light Blonde 18G','20329958721']]
  end
  
  def get_total_amount
    if session[:cart]
      price = 0
      session[:cart].each do |c|
        price = price.to_f + c[:price].to_f
      end
      return number_with_precision(price, :precision => 2)
    else
      return "0.00$"
    end 
  end
  
  def get_pic(product) 
    if product[:name] == "Mirror" 
      return '/assets/mrr.jpg'
    elsif product[:name] == "Water Resistant Spray"
      return '/assets/hi products/IMG_3191.jpg'
    elsif product[:name] == "Optimizer"
      return '/assets/optimizer.png'
    elsif product[:name] == "Laser Comb"
      return '/assets/laser_prod.jpg'
    elsif product[:name] == "Hair Illusion Fiber Hold Spray"
      return '/assets/fiber-hold.png'    
    elsif product[:name].include? "Value Pack 4"
       return '/assets/v4.jpg'    
    elsif product[:name].include? "Value Pack 3"
       return '/assets/v3.png' 
    elsif product[:name].include? "Value Pack 6"
       return '/assets/applicator_combo.jpg' 
    elsif product[:name].include? "Value Pack 2"
       return '/assets/v2.png' 
    elsif product[:name].include? "18g"
      return '/assets/hi products/IMG_8305.jpg'    
    elsif product[:name].include? "Value Pack 5"
       return '/assets/v5.png' 
    elsif product[:name].include? "Combo Pack"
       return '/assets/combo.jpg'   
    elsif product[:name].include? "Spray Applicator"
       return '/assets/applicator.jpg'   
    elsif product[:name].include? "Black 6g"
       return '/assets/6g_small.jpg'   
    else
      return '/assets/hi products/IMG_3666.jpg'    
    end
  end
  
  def get_sub_total
    sub_total = 0
    if session[:cart_obj] && session[:cart_obj].size > 0  
        session[:cart_obj].each do |d| 
          sub_total += d[:price].to_f
        end 
      end
      return sub_total
  end
  
  def get_shipping_price
    
    return session[:shipping_price] if session[:shipping_price] && session[:shipping_price].to_f > 0
    
    price = 0.0
    total_qty = 0
    product_count = 0
    value_count = 0
    if session[:cart_obj] && session[:cart_obj].size > 0   
        session[:cart_obj].each do |s|  
          if s[:name].include? "-"
            name = s[:name].split("-")[0] 
            product = Product.where(:description=>name).first 
            if product
              value_count += s[:quantity].to_i
              price += product.shipping_price.to_f/100*s[:quantity]
            end
          else
            product_count += s[:quantity].to_i
          end
        end
    end  

    if value_count == 0 && product_count > 0
      return @shipping_price + (product_count-1)
    elsif product_count > 0  
      #just add 1$ each to other products
      return price + @shipping_price + product_count-1
    else
      return price
    end  
    
  end
  
  def product_count
    count = 0
    if session[:cart_obj] && session[:cart_obj].size > 0  
      session[:cart_obj].each do |d| 
          count += d[:quantity].to_i 
        end 
    end
    return count
  end
  
  def get_percentage(a,b)  
    value = (1-(b.to_f/a.to_f)).to_f*100 
    return number_with_precision(value, :precision => 0)
  end
  
  def get_terms_text
    text_ss = 'We Will Ship You a Free 2 Weeks Supply Of The Color Of Your Choice With Free Shipping & Free Hairline Optimizer. Only Pay $8.95 For Process/Handing.
     
    Benefits Of Joining Our Hair Club.      
    
    Free Two Week Supply. 50% Off Retail Price. Never Run Out. Free Hairline Optimizer & Free Shipping With First Order. 30 Days After your Order And Every 30 Days After You Will Receive a Full Month Supply Of Hair Illusion. Only Pay $"#{@recurrent_price}". Charged to the card you provide today unless you cancel. No Commitment. You Can Cancel Any time Or Adjust Your Monthly Plan According To How Much Hair Illusion You Use.'
    return text_ss.html_safe
  end
  
  def get_css
   return " in" if @customer
   return ""
  end
  
  def get_active_css(page)
    if page == "dashboard"
      return "active" if(request.fullpath =~ /dashboard/ || request.fullpath =~ /edit_address/ )
    else
      return "active" if request.fullpath =~ /#{page}/
    end
  end
end
