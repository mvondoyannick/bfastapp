module CorePayment

  # merchant payment
  class Pay
    def initialize(argv)
      @phone = argv[:phone]
      @amount = argv[:amount]
      @external_references = argv[:external_reference]

    end

    # generate new token
    def getToken
      
      @query = HTTParty.post("https://campay.net/api/token/".to_str, {
        headers: {
          "Content-Type": "application/json"
        },
        body: {
          username: "lPL6d8KGYs7PFE7Sh7BZ_8oKgzfs-Ssa2RRmrLMPPIVDmCHid2Q8t9g8I5ngbzMw7eslg0gCly4vpJsTnRplTQ", #"kRYWwllGT-na3wfNQ35H0fFT3xLL6OBPv3bS53vUyxvzsl3rgueFMyc743kzxyovCuHnLdN8c_3PXBW7_ObNQw",
          password: "l3PeizHXDQv80TL8QQTAxqWc8D16jhTCmKnZooLzdk8oXZBIz1YK5vK_cMcJbJ_qCbEwUelvFcPR0VfBjSC4pw" #"sKaYo8_yEWqtA8v1sMSTvfB2Rj7n15OVMH9_JKwI7J7IO3EGO9wg-JG2MfIkO7dF6sqyit37dnKavs3pQ7U_eA"
        }.to_json
      })

      $campay_token = @query.parsed_response['token']

    end

    # debit user account
    def makeRequestToPay
      @query = HTTParty.post("https://campay.net/api/collect/".to_str, {
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token #{$campay_token}"
        },
        body: {
          amount: @amount,
          from: "237#{@phone}",
          description: "Test",
          external_reference: @external_references
        }.to_json
      })

      if @query.code == 200

        [true, "Transaction effectuée, merci de valider la transaction chez votre opérateur mobile money"]

      else

        [false, "Impossible de valider la transaction, merci de réessayer."]

      end

      #print response
      puts @query.parsed_response 
    end
  end
end