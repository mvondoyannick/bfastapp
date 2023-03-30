# typed: true
module Whatsapp
  class WhatsappMessages
    def initialize(phone, message)
      @phone = phone.to_s.length < 12 ? ApplicationHelper.update_phone_number(phone) : phone
      @message = message
    end

    def send_message 

      puts ApplicationHelper.update_phone_number(@phone)

      puts "send message to #{@phone}"

      require 'uri'
      require 'net/http' 

      begin

        url = URI("https://api.ultramsg.com/instance40780/messages/chat")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true 

        request = Net::HTTP::Post.new(url)
        request["content-type"] = 'application/x-www-form-urlencoded'
        form_data = URI.encode_www_form( {
          :token => 'mscf2mi80jlbrdvz',
          :to => "+#{ApplicationHelper.update_phone_number(@phone)}",
          :body => @message
        })
        request.body = form_data

        response = http.request(request)
        puts response.read_body
        
      rescue => exception

        puts "Une erreur est survenue : #{exception}"
        
      end

    end

  end

  class WhatsappImages
     def initialize(argv)
      @phone = argv[:phone]
      @file = argv[:file].present? ?  argv[:file] : "https://mppp-goshen.com/wp-content/uploads/2023/03/je_connais_ma_tension.png"
      @caption = argv[:caption]
     end

     def send_image
      

      require 'uri'
      require 'net/http' 

      url = URI("https://api.ultramsg.com/instance40780/messages/image")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true 

      request = Net::HTTP::Post.new(url)
      request["content-type"] = 'application/x-www-form-urlencoded'
      form_data = URI.encode_www_form( {
        :token => 'mscf2mi80jlbrdvz',
        :to => "+#{ApplicationHelper.update_phone_number(@phone)}",
        :image => @file,
        :caption => @caption
      })
      request.body = form_data

      response = http.request(request)
      puts response.read_body


     end

  end

  class WhatsappLocalization 
    def initialize(argv)
      @token = 'mscf2mi80jlbrdvz'
      @phone = argv[:phone]
    end

    def send_localisation
      

      require 'uri'
      require 'net/http' 

      url = URI("https://api.ultramsg.com/instance40780/messages/location")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true 

      request = Net::HTTP::Post.new(url)
      request["content-type"] = 'application/x-www-form-urlencoded'
      form_data = URI.encode_www_form( {
        :token => @token,
        :to => "+#{ApplicationHelper.update_phone_number(@phone)}",
        :address => 'Clinique coeur et vie, Ndogbong, Douala',
        :lat => '4.0552045',
        :lng => '9.74696'
      })
      request.body = form_data

      response = http.request(request)
      puts response.read_body


    end
  end
end