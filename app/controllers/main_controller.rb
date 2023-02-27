class MainController < ApiController
  #before_action :geolocalize, only: [:list_fournisseurs_gaz_bottle]

  # geolocation
  def geolocation
    results = Geocoder.search([params[:latitude], params[:longitude]])
    render json: {
      data: results.first.address
    }, status: :ok
  end

  # ======== MARKET
  # show categories
  def rayons
  end

  # search entreprise
  def search_entreprise
    @entreprise = Entreprise.ransack(params[:q]).result
    render json: {
      data: @entreprise.map do |entreprise|
        {
          name: entreprise.name
        }
      end
    }
  end

  # show entreprises
  def entreprises
    render json: {
      data: Entreprise.all.map do |entreprise|
        {
          name: entreprise.name.upcase,
          id: entreprise.id,
          has_agence: entreprise.as_agence,
          image: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(entreprise.logo, only_path: true)}"
        }
      end
    }
  end


  # show supermarche
  def supermarches
    #@entreprise = Entreprise.find(params[:supermarche_id]) 
    @supermarches = Distribution.where(entreprise_id: params[:supermarche_id])
    render json: {
      data: @supermarches.near([params[:latitude], params[:longitude]], 50).map do |supermarche|
        {
          id: supermarche.id,
          name: supermarche.name,
          logo: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(supermarche.logo, only_path: true)}",
          images: supermarche.images.map do |img|
            {
              "img_": "#{request.base_url}#{rails_blob_path(img)}"
            }
          end,
          distant: supermarche.distance_to([params[:latitude], params[:longitude]]).round(2),
          bearing: supermarche.bearing_to([params[:latitude], params[:longitude]])
        }
      end
    }, status: :ok
  end

  # show products
  def products
    @products = Product.where(distribution_id: params[:market_id])
    render json: {
      data: @products.map do |product|
        {
          supermarche: {
            name: product.distribution.name.upcase,
            logo: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(product.distribution.logo, only_path: true)}"
          },
          name: product.name,
          id: product.id,
          amount: product.amount,
          photos: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(product.image, only_path: true)}",
          galeries: product.galeries.map do |img|
            {
              "image": "#{request.base_url}#{rails_blob_path(img)}"
            }
          end
        }
      end
    }, status: :ok
  end

  # categories
  def product_categories
    @c = Category.all
    render json: {
      data: @c.map do |cate|
        {
          id: cate.id,
          name: cate.name,
          image: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(cate.logo, only_path: true)}"
        }
      end
    }, status: :ok
  end

  # lister tous les produits d'un rayon
  def rayons_products
    @rayon_products = Category.find(params[:cat_id]).products
    render json: {
      data: @rayon_products.map do |product|
        {
          name: product.name,
          id: product.id,
          image: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(product.image, only_path: true)}"
        }
      end
    }, status: :ok
  end

  # market payment
  def makeMarketPayment
    puts params.as_json
    render json: {
      message: "Paiement effectué"
    }, status: :ok
  end

  # ======== END MARKET

  # ======== TRAVEL BFAST
  # hour and minutes
  def hours_and_minutes
    if params[:day_selected].present?
      x = 0
      container = []
      @day_selected = params[:day_selected]

      # extract hour from @day_selected
      @hour_extracted = @day_selected.to_datetime.strftime("%H").to_i
      puts "Heure sent by client : #{@hour_extracted} | from class : #{@hour_extracted.to_i.class}"

      # check if this date is between beginning today and end today
      if @day_selected.between?(Date.today.beginning_of_day, Date.today.end_of_day)

        while x < 10
          a = Time.now + x.hours

          if @hour_extracted.to_i > a.strftime("%H").to_i
            # nothing to do
          else
            container << {hour: a.strftime("%H"), minute: a.strftime("%M")}
            puts "first while : #{container}"
          end
          x = x + 1
        end

      else

        while x < 10
          a = DateTime.new(2023,1,31,04,30) + x.hours
          container << {hour: a.strftime("%H"), minute: a.strftime("%M")}
          puts "last while : #{container}"
          x = x + 1
        end

      end

      # return some informations
      render json: container, status: :ok
    else
      render json: {
        message: "Une erreur est survenue"
      }, status: :unauthorized
    end

  end

  # day and month
  def days_and_month
    element = [
      {
        day: DateTime.now.strftime("%d"),
        name: DateTime.now.strftime("%A"),
        month: DateTime.now.strftime("%b"),
        slug: DateTime.now
      },
      {
        day: DateTime.now.days_since(1).strftime("%d"),
        name: DateTime.now.days_since(1).strftime("%A"),
        month: DateTime.now.days_since(1).strftime("%b"),
        slug: DateTime.now.days_since(1)
      },
      {
        day: DateTime.now.days_since(2).strftime("%d"),
        name: DateTime.now.days_since(2).strftime("%A"),
        month: DateTime.now.days_since(2).strftime("%b"),
        slug: DateTime.now.days_since(2)
      },
      {
        day: DateTime.now.days_since(3).strftime("%d"),
        name: DateTime.now.days_since(3).strftime("%A"),
        month: DateTime.now.days_since(3).strftime("%b"),
        slug: DateTime.now.days_since(3)
      },
      {
        day: DateTime.now.days_since(4).strftime("%d"),
        name: DateTime.now.days_since(4).strftime("%A"),
        month: DateTime.now.days_since(4).strftime("%b"),
        slug: DateTime.now.days_since(4)
      },
      {
        day: DateTime.now.days_since(5).strftime("%d"),
        name: DateTime.now.days_since(5).strftime("%A"),
        month: DateTime.now.days_since(5).strftime("%b"),
        slug: DateTime.now.days_since(5)
      }
    ]
    render json: element, status: :ok
  end

  # show all travel entreprises
  def travel_entreprise 
    @entreprises = TravelEntreprise.all 
    render json: {
      data: @entreprises.map do |entreprise|
        {
          name: entreprise.name.upcase,
          id: entreprise.id,
          token: entreprise.token,
          email: entreprise.email,
          phone: entreprise.phone,
          image: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(entreprise.image, only_path: true)}"
        }
      end
    }, status: :ok
  end

  # show travel_agences from selected entreprise
  def travel_agences
    if params[:latitude].present? && params[:longitude].present? && params[:travel_entreprise_id].present?
      @agences = TravelAgence.where(travel_entreprise_id: params[:travel_entreprise_id])
      render json: {
        data: @agences.near([params[:latitude], params[:longitude]], 50).map do |agence|
          {
            name: agence.name.upcase,
            id: agence.id,
            image: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(agence.image, only_path: true)}",
            distant: agence.distance_to([params[:latitude], params[:longitude]]).round(2),
            longitude: agence.longitude,
            latitude: agence.latitude
          }
        end
      }, status: :ok
      elsif params[:travel_entreprise_id].present?
      @agences = TravelAgence.where(travel_entreprise_id: params[:travel_entreprise_id])
      @ip = request.remote_ip
      results = Geocoder.search(@ip)
      @coordinates = results.first.coordinates
      render json: {
        data: @agences.near(@coordinates).map do |agence|
          {
            name: agence.name.upcase,
            id: agence.id,
            image: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(agence.image, only_path: true)}",
            distant: "Unknow", #agence.distance_to([params[:latitude], params[:longitude]]).round(2),
            longitude: agence.longitude,
            latitude: agence.latitude
          }
        end
      }, status: :ok
    else
      render json: {
        message: "Impossible de comprendre votre demande, informations manquantes"
      }, status: :unauthorized
    end
  end


  #==== GAZ SERVICES
  def list_gazs
    @gazs = GazBottle.all 
    render json: {
      data: @gazs.map do |gaz|
        {
          id: gaz.id,
          name: gaz.name,
          modele: "#{gaz.modele} Kg",
          amount: gaz.amount,
          image: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(gaz.image, only_path: true)}"
        }
      end
    }, status: :ok
  end

  # liste gaz fournisseurs sur la base d'une bouteille demandée
  # par le client
  def list_fournisseurs_gaz_bottle
    if params[:latitude].present? && params[:longitude].present? && params[:gaz_bottle_id].present?
      @bottle_id = params[:gaz_bottle_id]
      @fournisseurs = GazBottle.find(params[:gaz_bottle_id]).gaz_fournisseurs
      if @fournisseurs
        render json: {
          data: @fournisseurs.near([params[:latitude], params[:longitude]], 5).map do |fournisseur|
            {
              name: fournisseur.name,
              bottle: {
                name: GazBottle.find(params[:gaz_bottle_id]).name,
                id: GazBottle.find(params[:gaz_bottle_id]).id,
                amount: GazBottle.find(params[:gaz_bottle_id]).amount,
                modele: GazBottle.find(params[:gaz_bottle_id]).modele,
                token: GazBottle.find(params[:gaz_bottle_id]).token,
                image: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(GazBottle.find(params[:gaz_bottle_id]).image, only_path: true)}"
              },
              phone: GazBottle.find(params[:gaz_bottle_id]).phone,
              ville: GazBottle.find(params[:gaz_bottle_id]).ville.name,
              distant: fournisseur.distance_to([params[:latitude], params[:longitude]]).round(2),
            }
          end
        }
      else
        render json: {
          message: "Impossible de trouver des livreur de ce modèle de gaz"
        }, status: :not_found
      end
    elsif params[:gaz_bottle_id].present?
      @bottle_id = params[:gaz_bottle_id]
      @fournisseurs = GazBottle.find(params[:gaz_bottle_id]).gaz_fournisseurs
      @ip = Geocoder.search(request.remote_ip)
      @address = @ip.first.coordinates
      if @fournisseurs
        render json: {
          data: @fournisseurs.near(@address, 500).map do |fournisseur|
            {
              name: fournisseur.name,
              bottle: {
                name: GazBottle.find(params[:gaz_bottle_id]).name,
                id: GazBottle.find(params[:gaz_bottle_id]).id,
                amount: GazBottle.find(params[:gaz_bottle_id]).amount,
                modele: GazBottle.find(params[:gaz_bottle_id]).modele,
                token: GazBottle.find(params[:gaz_bottle_id]).token,
                image: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(GazBottle.find(params[:gaz_bottle_id]).image, only_path: true)}"
              },
              phone: fournisseur.phone,
              ville: fournisseur.ville.name,
              distant: fournisseur.distance_to(@adress).round(2),
            }
          end
        }
      else
        render json: {
          message: "Imposible de trouve ce modele de bouteille à gaz"
        }, status: :not_found
      end
    else
      render json: {
        message: "Impossible de trouver certaines informations de base, merci d'activer votre GPS"
      }, status: :unauthorized
    end
  end

  # @name create user account
  # signup account
  def create 
    if params[:credential].present? && params[:name].present? && prams[:password].present? && params[:confirm_password].present?
      # validate the phone or the email adress
      if params[:credential].match? Devise.email_regexp
      elsif Phonelib.valid_for_country? params[:credential], 'CM'
        # check password
        if params[:password] == params[:confirm_password]
          # we can create
          @query = Customer.new(
            phone: params[:phone],
            password: params[:password],
            name: params[:name],
            admin: false,
            role_id: Role.find_by_name('bfast').id
          )

          if @query.save 
            # generate OTP
            @otp = generate_otp(phone, @query.id)
            render json: {
              message: "Welcome",
              verification_token: "78768"
            }, status: :ok
          else
            render json: {
              message: @query.errors.messages
            }, status: :unauthorized
          end
        else
          render json: {
            message: "Les mots de passe diffèrent, merci de les modifier et de réessayer"
          }, status: :unauthorized
        end

      else
        render json: {
          message: "Numéro de téléphone inconnu ou invalide, merci de vérifier ou de réessayer"
        }, status: :unauthorized
      end
    else
      render json: {
        message: ""
      }, status: :unauthorized
    end
  end

  # generate magic OTP
  def generate_otp(phone, user_id)
    @phone = phone 
    @user = Customer.find(user_id)
    if @user
      # generate otp, save and send SMS notification
    else
    end
  end

  # check verification login
  def login
    if params[:credential].present?
      @credential = params[:credential]
      # check if it's a password
      if @credential.match? Devise.email_regexp
        # this an email
        @query = email_login(@credential)
        if @query[0] == false
          render json: {
            message: @query[1],
            type: :email
          }, status: :not_found
        else
          render json: {
            message: @query[1],
            type: :email
          }, status: :ok
        end
      elsif Phonelib.valid? @credential
        # this is a phone
        @query = phone_login(@credential)
        if @query[0] == false 
          render json: {
            message: @query[1],
            type: :email
          }, status: :not_found
        else
          render json: {
            message: @query[1],
            type: :email
          }, status: :ok
        end
      else
        render json: {
          message: "Impossible de trouver le compte associé à #{@credential}"
        }, status: :not_found
      end
    else
      render json: {
        message: "Impossible de vous authentifier, informations manquantes"
      }, status: :unauthorized
    end
  end

  # login with email
  def email_login(email)
    @email = email
    if @email.match? Devise.email_regexp
      a = Customer.find_by(email: @email, role_id: Role.find_by_name("bfast").id)
      if a
        return [true, a.as_json(only: [:email, :name, :token])] 
      else
        return [false, "Impossible trouver le compte associé à l'adresse email #{@email}, merci de modifier. \n\nSouhaitez-vous creer un compte avec l'adresse email #{@email}?"]
      end
    else
      return [false, "L'email founis n'est pas correcte, merci de la modifier et de réessayer"]
    end
    
  end

  # login with phone
  def phone_login(phone)
    @phone = phone
    if Phonelib.valid_for_country? @phone, 'CM'
      a = Customer.find_by(phone: @phone, role_id: Role.find_by_name("bfast").id)
      if a
        return [true, a.as_json(only: [:email, :name, :token])] 
      else
        return [false, "Impossible trouver le compte associé au numéro de téléphone #{@phone}, merci de modifier. \n\nSouhaitez-vous creer un compte avec le numéro #{@phone}?"]
      end
    else
      return [false, "Le numéro de téléphone fournis est invalide, merci de réessayer de nouveau"]
    end
  end

  def check_paiement
    if params[:reservation_token].present?
      if Reservation.exists?(token: params[:reservation_token])
        @reservation = Reservation.find_by(token: params[:reservation_token])
        if @reservation.paid == true 
          render json: {
            message: "Paiement effectuée et validé"
          }, status: :ok
        else
          render json: {
            message: "Paiement en attente de validation"
          }, status: :unauthorized
        end
      else
        render json: {
          message: "Cette reservation n'existe pas ou a été supprimée"
        }, status: :unauthorized
      end
    else
      render json: {
        message: "Information de paiement manquant"
      }, status: :unauthorized
    end
  end

  def webhook
    if params[:external_reference].present?
      if Reservation.exists?(token: params[:external_reference], paid: false)
        @reservation = Reservation.find_by(token: params[:external_reference], paid: false)
        if params[:status] == "FAILED"
          @reservation.paid = false
          if @reservation.save
            # create paiment object
            @pay = TravelTransaction.new(
              reservation_id: @reservation.id,
              amount: params[:amount],
              reference: params[:reference],
              tstatus: params[:status],
              currency: params[:currency],
              operator: params[:operator],
              code: params[:code],
              external_reference: params[:external_reference]
            )
  
            if @pay.save 
              sms = Sms::Sms.new(phone: @phone, message: "Le paiement de votre billet à destination de #{@reservation.depart} n'a pas été validé, il sera annulé dans quelques minutes. Merci de nous faire confiance")
              sms.generate_token
              sms.send
            else
              render json: {
                message: "Impoossible de creer votre ticket"
              }, status: :unauthorized
            end
          else
            render json: {
              message: "La reservation n'a pas pu être mise à jour"
            }, status: :unauthorized
          end
        else
          @reservation.paid = true 
          if @reservation.save
            # create paiment object
            @pay = TravelTransaction.new(
              reservation_id: @reservation.id,
              amount: params[:amount],
              reference: params[:reference],
              tstatus: params[:status],
              currency: params[:currency],
              operator: params[:operator],
              code: params[:code],
              external_reference: params[:external_reference]
            )
  
            if @pay.save 
              sms = Sms::Sms.new(phone: @phone, message: "Le paiement de votre billet à destination de #{@reservation.depart} à été validé, vous pouvez commencer à faire vos valides. Le lien tu billet electronique est ici https://google.com/ici")
              sms.generate_token
              sms.send
            else
              render json: {
                message: "Impoossible de creer votre ticket"
              }, status: :unauthorized
            end
          else
            render json: {
              message: "La reservation n'a pas pu être mise à jour"
            }, status: :unauthorized
          end
        end
      else
        render json: {
          message: "Cette reservation n'existe pas"
        }, status: :unauthorized
      end
    else
      render json: {
        message: "Information manquantes"
      }, status: :unauthorized
    end
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
        customer_name: params[:name] ||= "Unknow",
        customer_phone: params[:phone] ||= "Not defined",
        depart: params[:voyage][:depart],
        arrivee: params[:voyage][:arrivee],
        date_depart: "#{params[:voyage][:jour_depart]} #{params[:voyage][:mois_depart]} 2023",
        customer_id: Customer.first.id,
        heure: "#{params[:voyage][:heure_depart]}:#{params[:voyage][:minute_depart]}",
        amount: params[:pay][:amount],

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
    lt = 'Littoral' # Definition de la ville du littoral
    ce = 'Centre' # Definition de la region du Centre
    puts "Headers informations : #{request.headers['HTTP_LATITUDE']} -- #{request.headers['HTTP_LONGITUDE']}"
    puts Geocoder.search(request.remote_ip).first.address
    if request.headers['HTTP_LATITUDE'].present? && request.headers['HTTP_LONGITUDE'].present? && request.headers['HTTP_LATITUDE'] =! 'undefined' && request.headers['HTTP_LONGITUDE'] =! 'undefined'
      results = Geocoder.search([request.headers['HTTP_LATITUDE'], request.headers['HTTP_LONGITUDE']])
      render json: {
        mode: :coordonnees,
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
        mode: :ip,
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
        @current_customer.otp = @otp 
        if @current_customer.save 

          # send via SMS Gateway
          #if params[:customer][:phone] != "691451189"
            sms = Sms::Sms.new(phone: @phone, message: "Votre code de vérification OTP BFAST est le suivant #{@current_customer.otp}, \nil est valable 1 minute")
            sms.generate_token
            sms.send
          #end

          render json: {
            token: @current_customer.token,
            message: "Saisir le code à six chiffres reçu par SMS au numéro #{@phone} pour confirmer que vous êtes propriétaire de ce compte"
          }, status: :ok
        else
          render json: {
            token: @current_customer.token,
            message: @current_customer.errors.messages
          }, status: :unauthorized
        end
      else
        
        # generate OTP
        totp = ROTP::TOTP.new("base32secret3232", issuer: "BFast")
        @otp = totp.now

        # create new customer
        @customer = Customer.new(phone: params[:customer][:phone], otp: @otp, email: "#{@phone}@bfast.com", password: 123456)
        if @customer.save 
          # send via SMS Gateway
          #if params[:customer][:phone] != "691451189"
            sms = Sms::Sms.new(phone: @phone, message: "Votre code de vérification OTP BFAST est le suivant #{@customer.otp}, \nil est valable 1 minute")
            sms.generate_token
            sms.send
          #end

          render json: {
            token: @customer.token,
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

  # validate OPT
  def verify_otp
    if params[:otp].present? && params[:token].present? && params[:user][:phone].present?
      # find this customer
      if Customer.exists?(phone: params[:user][:phone], otp: params[:otp], token: params[:token])
        @customer = Customer.find_by(phone: params[:user][:phone], otp: params[:otp], token: params[:token])

        # remove this otp
        @customer.otp = nil

        # try to save
        if @customer.save 
          # create transaction
          @reservation = Reservation.new(
            customer_id: @customer.id,
            depart: params[:voyage][:depart],
            arrivee: params[:voyage][:arrivee],
            date_depart: params[:voyage][:date_depart],
            heure: params[:voyage][:heure],
            customer_phone_payment: params[:pay][:phone_pay],
            amount: params[:pay][:amount],
            paid: false,
            fee: 0
          )

          # try to save
          if @reservation.save 
            # lauche Mobile money payment request
            @transaction = CorePayment::Pay.new(phone: params[:user][:phone], amount: params[:pay][:amount], external_reference: @reservation.token)
            @transaction.getToken
            @transaction.makeRequestToPay

            render json: {
              message: "Reservation registered succefull",
              reservation: {
                token: @reservation.token,
                customer_token: @customer.token
              }
            }, status: :created
          else
            render json: {
              message: "Impossible d'enregistrer votre reservation : #{@r.errors.messages}"
            }, status: :unauthorized
          end
        else
          render json: {
            message: "Impossible de valider cet OTP : #{@customer.errors.messages}"
          }, status: :unauthorized
        end

      else
        render json: {
          message: "Impossible de continuer, compte ou  utilisateur inexistant"
        }, status: :unauthorized
      end
    else
      render json: {
        message: "Informations manquantes ou incompletes"
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

  # ALL ABOUT USER ACCOUNT
  # ============== BEGIN ===========
  # create new account from user
  def signup 
    if params_signup.present?
      puts params.as_json
    else
      render json: {
        message: "Lorem error"
      }, status: :unauthorized
    end
  end

  # login customer account from APP
  def login_me
    if params[:phone_me].present? && params[:password_me].present?

      if Phonelib.valid? params[:phone_me]
        if Customer.exists?(phone: params[:phone_me])
          @customer = Customer.find_by(phone: params[:phone_me])
          if @customer&.valid_password? params[:password_me]
            # generate and register OTP password before send
            # generate OTP
            totp = ROTP::TOTP.new("base32secret3232", issuer: "BFAST")
            @otp = totp.now

            # begin to update customer
            @customer.otp = @otp
            if @customer.save
              # send via SMS
              # @sms = Sms::Sms.new(phone: params[:phone_me], message: "Votre code OTP BFAST de connexion est #{@otp}.\nGardez-le precieusement car il n'est utilisable qu'une seul fois.")
              # @sms.generate_token
              # @sms.send

              #respond with #200 status
              render json: {
                token: @customer.token,
                email: @customer.email
              }, status: :ok
            else
              render json: {
                message: "Erreur survenue : #{@customer.errors.details}"
              }, status: :unauthorized
            end


          else
            render json: {
              message: "Utilisateur ou mot de passe invalide"
            }, status: :unauthorized
          end
        else
          render json: {
            message: "Utilisateur ou compte introuvble"
          }, status: :not_found
        end
      else
        render json: {
          message: "Numéro de téléphone invalide ou mal formé. Merci de modifier et de réessayer"
        }, status: :unauthorized
      end
    else
      render json: {
        message: "Impossible de vous identifier, informations manquantes"
      }, status: :unauthorized
    end
  end

  # validate OTP incomming
  def check_otp
    if params[:token_me].present? && params[:otp_me].present?
      if Customer.exists?(otp: params[:otp_me], token: params[:token_me])
        @customer = Customer.find_by(otp: params[:otp_me], token: params[:token_me])
        @customer.otp = nil
        if @customer.save
          render json: {
            name: @customer.name,
            phone: @customer.phone,
            token: @customer.token
          }, status: :ok
        else
          render json: {
            message: "Erreur survenue : #{@customer.errors.details}"
          }, status: :unauthorized
        end
      else
        render json: {
          message: "Impossible de trouver ce code d'identification OTP"
        }, status: :not_found
      end
    else
      render json: {
        message: "Informations de vérifications manquantes"
      }, status: :not_found
    end
  end
  # ============== END =============
  # END

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


  private
  def geolocalize
    unless params[:latitude].present? && params[:longitude].present?
      render json: {
        message: "Certaines informations de localisation sont indisponibles, merci d'activer votre GPS et de réessayer"
      }, status: :unauthorized
    end
  end

  # white params signup
  def signup_params
    params.permit(:name, :sexe, :password, :phone)
  end

end
