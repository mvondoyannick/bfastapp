module CorePayment
  class Pay 
    def initialize(argv)
      @phone = argv[:phone]
      @amount = argv[:amount]
    end

    # generate token
    def generate_token
    end

    # make payment
    def make_payment
    end
  end
end