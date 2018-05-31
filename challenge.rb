  require 'rubygems'
  require 'json'
  require 'net/http'


  def api_response(id, page)
    uri = URI.parse("http://backend-challenge-fall-2018.herokuapp.com/carts.json")
    params = { id: id, page: page }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    JSON.parse(res.body)
  end

  def cart_total(options, pages)
    # options contains 'id', 'pages', 'discount_value' and 'cart_value' in a hash
    cur_page = 1
    total_amount = 0.to_f
    total_after_discount = 0.to_f
    
    while cur_page <= options[:pages] do
      res = api_response(options[:id], cur_page)
      if options[:discount_type] == "cart"
        res['products'].each do |product|
          total_amount += product['price']
        end
        
        if total_amount >= options[:cart_value] && cur_page == options[:pages]
          total_after_discount = total_amount - options[:discount_value]
        elsif cur_page == options[:pages]
          total_after_discount = total_amount
        end 
      elsif options[:discount_type] == "product" && options[:collection]
        res['products'].each do |product|
          total_amount += product['price']
          if product['collection'] == options[:collection]
            total_after_discount += product['price'] - options[:discount_value] if product['price'] > options[:discount_value]
          else 
            total_after_discount += product['price']
          end
        end
      else # product value
        res['products'].each do |product|
          total_amount += product['price']
          if product['price'] >= options[:product_value]
            total_after_discount += product['price'] - options[:discount_value] if options[:discount_value] <= product['price']
          else 
            total_after_discount += product['price']
          end
        end
      end

      cur_page += 1
    end

    puts JSON.pretty_generate({ total_amount: total_amount, total_after_discount: total_after_discount })
  end

  def calculate_discount
    params = JSON.parse(gets.chomp)
    id = params['id']
    res = api_response(id, 1)
    pages = (res['pagination']['total'].to_f / res['pagination']['per_page']).ceil
    discount_type = params['discount_type']
    discount_value = params['discount_value']

    options = { id: id, pages: pages, discount_value: discount_value }

    if discount_type == "cart"
      options.merge!({ cart_value: params['cart_value'], discount_type: "cart" })
      cart_total(options, pages)
    else
      if !params['collection'].nil?
        options.merge!({ collection: params['collection'], discount_type: "product"})
        cart_total(options, pages)
      else
        options.merge!({ product_value: params['product_value'], discount_type: "product" })
        cart_total(options, pages)
      end
    end
  end

calculate_discount