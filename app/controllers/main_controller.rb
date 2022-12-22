class MainController < ApiController
  def index
  end

  def give_hours
    if (params[:day].to_i == Date.today.year.to_i)
      
      @times = Horaire.where(departure: DateTime.now..(Date.today.end_of_day))
      render json: {
        data: @times.map do |time|
          {
            time: time.departure.strftime("%Hh:%Mmin"),
            id: time.id
          }
        end
      }, status: :ok

    elsif Time.now.day == params[:day].to_datetime.day
      @times = Horaire.where(departure: params[:day].to_datetime..(Date.today.end_of_day))
      render json: {
        data: @times.map do |time|
          {
            time: time.departure.strftime("%Hh:%Mmin"),
            id: time.id
          }
        end
      }, status: :ok
    elsif Time.now.day < params[:day].to_date.day
      # il fait sa commande aujourd'hui pour une date futur
      puts :not
      puts params[:day].to_date.day
      puts Time.now.day
      @times = Horaire.where(departure: Date.today.beginning_of_day..Date.today.end_of_day) 
      render json: {
        data: @times.map do |time|
          {
            time: time.departure.strftime("%Hh:%Mmin"),
            id: time.id
          }
        end
      }, status: :ok
    else
      @times = Horaire.all 
      render json: {
        data: @times.map do |time|
          {
            time: time.departure.strftime("%Hh:%Mmin"),
            id: time.id
          }
        end
      }, status: :ok
    end
    
  end

  def makepayment
    if params[:voyage].present? && params[:user].present? && params[:pay].present? && params[:enterprise].present?

      @reservation = Reservation.new(
        horaire_id: Horaire.first.id,
        bus_id: Bus.first.id,
        ville_id: Ville.first.id,
        customer_name: params[:user]["name"].to_s,
        customer_second_name: params[:user]["second_name"].to_s,
      )

      if @reservation.valid?

        # before save call payment module
        @reservation.save

        render json: {
          message: "Information et voyage enregistré"
        }, status: :ok
      else
        render json: {
          message: @reservation.errors.messages
        }, status: :not_found
      end

    else
      render json: {
        message: "Information manquantes, merci de réessayer"
      }, status: :not_found
    end
  end

  # enabled devise deolocation
  def geolocate_this
    # geolocation cordinate
    lt = 'Littoral'
    ce = 'Centre'
    if request.headers['HTTP_LATITUDE'].present? && request.headers['HTTP_LATITUDE'].present? && !request.headers['HTTP_LATITUDE'].nil?
      results = Geocoder.search([request.headers['HTTP_LATITUDE'], request.headers['HTTP_LONGITUDE']])
      render json: {
        geolocation: results.nil? ? Geocoder.search(request.remote_ip).first.address : "#{results.first.address.split(",")[0]} - #{results.first.address.split(",")[1]}",
        message: "Geolocalized via coordinates",
        datas: {
          ville: results.first.address.split(",")[5].nil? ? nil : results.first.address.split(",")[5],
          region: results.first.address.split(",")[4].nil? ? nil : results.first.address.split(",")[4],
          arrondissement: results.first.address.split(",")[3].nil? ? nil : results.first.address.split(",")[3],
          communaute: results.first.address.split(",")[2].nil? ? nil : results.first.address.split(",")[2],
          arr: results.first.address.split(",")[1].nil? ? nil : results.first.address.split(",")[1],
          quartier: results.first.address.split(",")[0].nil? ? nil : results.first.address.split(",")[0],
        },
        departure: results.first.address.split(",")[4].delete(" ").eql?("Littoral") ? "Douala" : "Yaoundé",
        destination: results.first.address.split(",")[4].delete(" ").eql?("Littoral") ? "Yaoundé" : "Douala"
      }, status: :ok
      return
    else
      # we have not found geolocation on header, get remote IP adresse
      @ip_adress = request.remote_ip

      # call geocoder for IP Adress request
      render json: {
        geolocation: Geocoder.search(request.remote_ip),
        message: "Geolocalized via IP address"
      }, status: :ok
      return
    end
  end

  # request OTP
  def request_otp
    if params[:phone].present? && params[:customer].present?
      @phone = params[:phone]

      # check if this customer exist
      if Customer.exists?(phone: params[:customer][:phone])
        @current_customer = Customer.find_by(phone: params[:customer][:phone])
        # generate OTP
        totp = ROTP::TOTP.new("base32secret3232", issuer: "BFast")
        @otp = totp.now

        # put this customer update
        @customer.otp = @otp 
        if @customer.save 

          render json: {
            message: "Saisir le code à six chiffres reçu par SMS au numéro #{@phone} pour confirmer que vous êtes propriétaire de ce compte"
          }, status: :ok
        else
          render json: {
            message: @customer.errors.messages
          }, status: :unauthorized
        end
      else
        
        # generate OTP
        totp = ROTP::TOTP.new("base32secret3232", issuer: "BFast")
        @otp = totp.now

        # create new customer
        @customer = Customer.new(phone: params[:customer][:phone], otp: @otp)
        if @customer.save 
          # send via SMS Gateway
          sms = Sms::Sms.new(phone: @phone, message: "Votre code de vérification OTP BFAST est le suivant #{@customer.otp}, \nil est valable 1 minute")
          sms.generate_token
          sms.send

          render json: {
            message: "Saisir le code à six chiffres reçu par SMS au numéro #{@phone} pour confirmer que vous êtes propriétaire de ce compte"
          }, status: :ok

        else
          render json: {
            message: @customer.errors.messages
          }, status: :unauthorized
        end
      end

    else

      render json: {
        message: "Informations invalides ou manquantes"
      }, status: :unauthorized
    end
  end

  # authenticate customer from mobile APP
  def auth_user_app
    if params[:phone].present? && params[:password].present?
    else
      render json: {
        message: "Utilisateur ou mot de passe manquant, merci de réessayer"
      }, status: :ok
    end
  end 

  # create new user account
  def new_account_app 
  end

  # START TRAVEL INFORMATIONS
  # ====================== BEGIN =======================
  # automatiquement identifier la ville de destination
  def ville_dest
    @response = geolocate_this(request)
    if @response == "Yaoundé"
      puts "current time : #{Time.now}"
      render json: {

      }, status: :ok
      return
    elsif @response == "Douala"
      render json: {

      }, status: :not_found
      return
    else
      render json: {
        message: "Impossible de determiner votre position, merci d'activer votre GPS"
      }, status: :not_found
      return
    end
  end
  # ======================= END ========================

end
