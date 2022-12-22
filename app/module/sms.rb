module Sms
  class Sms 

    # initialize
    def initialize(argv)
      @phone = argv[:phone]
      @message = argv[:message]
      @api_key = "e03d26a0-4f17-42e1-aba7-160a72a62be9"
      @api_secret = "7de3543526b3769aa7184526ef17179e"
    end

    def generate_token
      result = HTTParty.post("https://api.web2sms237.com/token",
      basic_auth: {
        username: @api_key,
        password: @api_secret
      })

      $bearer_key = result.parsed_response['access_token']
    end

    # send SMS
    def send
      require 'uri'
      require 'json'
      require 'net/http'

      url = URI("https://api.web2sms237.com/sms/send")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true 

      request = Net::HTTP::Post.new(url)
      request["Authorization"] = "Bearer #{$bearer_key}"
      request["Content-Type"] = "application/json"
      request.body = JSON.dump(
        {
          "sender_id": "BFAST",
          "phone": "+237#{@phone}",
          "text": @message,
          "flash": false
        }
      )

      response = https.request(request)
      puts response.read_body

    end

  end

end