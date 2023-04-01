class FocevController < ApiController

  def entry 
    render json: {
      'message': 'hello'
    }
  end
    
  def index
    if (params['data'].present? )

      @instance = 'none'
      puts params
      @body = params['data']['body']
      @name = params['data']['pushname']
      @phone = params['data']['from'].delete('@c.us')

      if 'autre'.in? @body.downcase 

        if Customer.exists?(phone: @phone)

          # get the customer
          @customer = Customer.find_by_phone(@phone)

          # make the query
          query = Whatsapp::WhatsappMessages.new(@phone, "Merci de nous faire confiance #{@customer.real_name}, vous avez demandé à effectuer un autre enrollement pour un tierce personne?")
          query.send_message
        else

          # sorry
          query = Whatsapp::WhatsappMessages.new(@phone, "Merci mais nous ne retrouvons pas vos informations dans notre système!! Souhaitez-vous commencer par connaitre votre tension?")
          query.send_message
        end
      elsif 'continuer'.in? @body.downcase
        q = Whatsapp::WhatsappMessages.new(@phone, "Cette fonctionnalitée de rappel n'est pas encore implemntée, nous avons pris connaissance de votre relance.")
        q.send_message   
      else

        # search this customer
        @customer = Customer.find_by_phone(@phone)
        if @customer
          @customer.update(ip: request.remote_ip)
          puts "il existe deja un customer, #{@customer.steps} on verifie les étapes deja franchis"
          if @customer.steps.nil?
            # case @instance
            # when "none"
            #   # we have to call salutation
            #   salutation
            # when "salutation"
            #   # we have to ask sexe
            #   sexe
            # else
            #   age
            # end
          elsif @customer.steps == '1'
            # on enregistre le nom
            @customer.update(real_name: @body)
            @customer.update(steps: 2)

            sleep 1
            # send next message
            query = Whatsapp::WhatsappMessages.new(@phone, "Merci *#{@customer.real_name.upcase}*, votre nom est original. Quel est votre sexe?")
            query.send_message
            
            sleep 1
            masculin = Whatsapp::WhatsappMessages.new(@phone, "Saisir 1 pour Masculin 🙋🏽‍♂ ")
            masculin.send_message

            sleep 1
            feminin = Whatsapp::WhatsappMessages.new(@phone, "Saisir 2 pour Féminin 🙋🏽‍♀ ")
            feminin.send_message

          elsif @customer.steps == '2'
            # on enregistre le sexe
            if @body == '1'
              @customer.update(sexe: 'masculin')
              @customer.update(steps: 3)
            elsif @body == '2'
              @customer.update(sexe: 'feminin')
              @customer.update(steps: 3)
            else
              # invalide sexe
              query = Whatsapp::WhatsappMessages.new(@phone, "Merci de selectionner un sexe valide #{@customer.appelation}. Quel est votre sexe?")
              query.send_message
              
              sleep 1
              masculin = Whatsapp::WhatsappMessages.new(@phone, "Saisir 1 pour Masculin 🙋🏽‍♂ ")
              masculin.send_message

              sleep 1
              feminin = Whatsapp::WhatsappMessages.new(@phone, "Saisir 2 pour Féminin 🙋🏽‍♀ ")
              feminin.send_message
            end
            

            sleep 1
            # send next message
            query = Whatsapp::WhatsappMessages.new(@phone, "Merci #{@customer.appelation}. Serait'il possible de connaitre votre âge?")
            query.send_message
        
          elsif @customer.steps == '3'
            @customer.update(age: @body)
            @customer.update(steps: 'QT') # QT = Question Tensiometre

            sleep 1
            # send next message
            query = Whatsapp::WhatsappMessages.new(@phone, "Maintenant nous allons passer aux informations *médicales*, à savoir prendre votre tension arterielle #{@customer.appelation}. Mais avant nous souhaiterions nous rassurer d'une chose")
            query.send_message

            # ====== other
            sleep 1
            # check if customer have tools
            query0 = Whatsapp::WhatsappMessages.new(@phone, "Avez-vous un *tensiomètre* à votre disposition actuellement #{@customer.appelation}.")
            query0.send_message

            sleep 1
            a = Whatsapp::WhatsappMessages.new(@phone, "Saisir *A* si vous avez un tensiomètre")
            a.send_message

            sleep 1
            b = Whatsapp::WhatsappMessages.new(@phone, "Saisir *B* si vous n'en avez pas sur place/à disposition")
            b.send_message

            sleep 1
            c = Whatsapp::WhatsappMessages.new(@phone, "Saisir *C* pour savoir ce que c'est un *tensiomètre*") #https://fr.wikipedia.org/wiki/Tensiomètre #https://fr.wikihow.com/lire-sa-tension-artérielle-avec-un-tensiomètre
            c.send_message

              # query2 = Whatsapp::WhatsappMessages.new(@phone, "Merci de me fournir la premiere valeur afficher par votre tensiometre, celle du dessus #{@customer.appelation}.")
              # query2.send_message
          
          elsif @customer.steps == 'QT'
            @customer.update(question_tension: @body.downcase)

            case @customer.question_tension
            when 'a'
              # il n'a pas de tensiometre
              @customer.update(steps: 4)

              # tout va bien
              get = Whatsapp::WhatsappMessages.new(@phone, "OK #{@customer.appelation} de nous fournir la tension (diastole) de votre bras droit")
              get.send_message

            when 'b'
              @customer.update(steps: 'no_tension')
              # il ya un probleme, merci de fournir le bras gauche  
              no = Whatsapp::WhatsappMessages.new(@phone, "Hum, vous semblez ne pas avoir de tensiometre sous la main. Pourrions nous vous revenir suivant les options que proposées? #{@customer.appelation}?")
              no.send_message

              sleep 1
              d = Whatsapp::WhatsappMessages.new(@phone, "Saisir 1 Pour être rappelé(e) dans 24h *(demain)*")
              d.send_message

              sleep 1
              c = Whatsapp::WhatsappMessages.new(@phone, "Saisir 2 Pour être rappelé(e) dans 72h *(3 jours)*")
              c.send_message

              sleep 1
              e = Whatsapp::WhatsappMessages.new(@phone, "Saisir 3 Pour être rappelé(e) dans *5 jours*")
              e.send_message

              sleep 1
              f = Whatsapp::WhatsappMessages.new(@phone, "Saisir 4 Laissez moi un peu de temps, je vous reviendrais.")
              f.send_message
            when 'c'
              # il veut en apprendre plus
              # @customer.update(steps: 5)

              query = Whatsapp::WhatsappMessages.new(@phone, "Vous souhaitez en apprendre plus sur le tensiomètre, nous avons deux articles pour vous #{@customer.appelation}.")
              query.send_message

              sleep 1
              wiki = Whatsapp::WhatsappMessages.new(@phone, "*Wikipedia* nous présente le tensiometre \n\nhttps://fr.wikipedia.org/wiki/Tensiomètre")
              wiki.send_message

              sleep 1
              pedia = Whatsapp::WhatsappMessages.new(@phone, "*WikiHow* pour apprend comment lire un tensiomètre \n\nhttps://fr.wikihow.com/lire-sa-tension-artérielle-avec-un-tensiomètre")
              pedia.send_message

              sleep 2
              # check if customer have tools
              query0a = Whatsapp::WhatsappMessages.new(@phone, "Avez-vous un *tensiomètre* à votre disposition actuellement #{@customer.appelation}.")
              query0a.send_message

              sleep 1
              a1 = Whatsapp::WhatsappMessages.new(@phone, "Saisir *A* si vous avez un tensiomètre")
              a1.send_message

              sleep 1
              b2 = Whatsapp::WhatsappMessages.new(@phone, "Saisir *B* si vous n'en avez pas sur place/à disposition")
              b2.send_message

          
            else
              
            end
          
          elsif @customer.steps == 'no_tension'
            @customer.update(rappel: @body)
            @customer.update(steps: 'need_rappel')
            @customer.update(rappel_day: @body)

            sleep 1
            text = Whatsapp::WhatsappMessages.new(@phone, "Merci, nous allons vous revenir dans #{@customer.rappel} jour(s). Passez une bonne semaine. \n\nPensez à visiter le site de la Fondation Coeur et Vie à l'adresse www.coeuretvie.org")
            text.send_message

          elsif @customer.steps == 'need_rappel'

            text = Whatsapp::WhatsappMessages.new(@phone, "Hello #{@customer.real_name}, notre rappel à lieu dans #{@customer.rappel} jour(s), nous vous relancerons dans ces delais. Si par contre vous disposez deja vos parametres de tension, merci de saisir *continuer*.")
            text.send_message

          elsif @customer.steps == '4'
            @customer.update(tension_droit: @body)

            case @customer.tension_droit.to_i
            when 90..140
              # on passe a t'etape 5
              @customer.update(steps: 5)

              # tout va bien
              query = Whatsapp::WhatsappMessages.new(@phone, "Merci #{@customer.appelation}, vous le faite comme un pro, maintenant nous aurons besoin de la deuxième valeur en dessous de le première, elle est légèrement plus petite?")
              query.send_message
            when 40..90
              @customer.update(steps: 5)
              # il ya un probleme, merci de fournir le bras gauche  
              query = Whatsapp::WhatsappMessages.new(@phone, "Hum, pour confirmation...merci de nous fournir la tension artérielle de votre bras gauche #{@customer.appelation}.")
              query.send_message
            when 140..250
              # c'est grave, consulter à l'immédiat
              @customer.update(steps: 5)

              query = Whatsapp::WhatsappMessages.new(@phone, "Hum, pour confirmation...merci de nous fournir la tension artérielle de votre bras gauche #{@customer.appelation}.")
              query.send_message
          
            else
              
            end

          elsif @customer.steps == '51'
            # read diastole droit
            @customer.update(diastole_droit: @body)
            @customer.update(steps: 52)

            sleep 1
            query = Whatsapp::WhatsappMessages.new(@phone, "super, c'est enregistré, maintenant entrer la dernière valeur qui est votre poul du bras droit (battement de coeur), c'est la plus petite des valeurs sur le tensiometre #{@customer.appelation}")
            query.send_message

          elsif @customer.steps == '52'

            # read diastole droit
            @customer.update(poul_droit: @body)
            @customer.update(steps: 8)

            sleep 1
            query = Whatsapp::WhatsappMessages.new(@phone, "super! Nous sommes presqu'a la fin. C'est possible que je puisse savoir dans quel quatier est ce que vous résidez #{@customer.appelation}?")
            query.send_message

          elsif @customer.steps == '5'
            @customer.update(tension_gauche: @body)

            case @customer.tension_gauche.to_i
            when 0..60
              # on passe a t'etape 5
              @customer.update(steps: 6)

              # prochaine question, le quartier
              sleep 1
              query = Whatsapp::WhatsappMessages.new(@phone, "super, nous sommes presqu'a la fin. C'est possible que je puisse savoir dans quel quatier est ce que vous résidez #{@customer.appelation}?")
              query.send_message

            when 60..90
              @customer.update(steps: 6)
              # il ya un probleme, merci de fournir le bras gauche  
              sleep 1
              query = Whatsapp::WhatsappMessages.new(@phone, "super, nous sommes presqu'a la fin. C'est possible que je puisse savoir dans quel quatier est ce que vous résidez #{@customer.appelation}")
              query.send_message
            when 90..300
              # c'est grave, consulter à l'immédiat
              @customer.update(steps: 6)
              sleep 1
              query = Whatsapp::WhatsappMessages.new(@phone, "super, nous sommes presqu'a la fin. C'est possible que je puisse savoir dans quel quatier est ce que vous résidez #{@customer.appelation}?")
              query.send_message
            end

          elsif @customer.steps == '511'
            @customer.updaye(diastole_gauche: @body)
            @customer.update(steps: 521)

            sleep 1
            query = Whatsapp::WhatsappMessages.new(@phone, "super, c'est enregistré, maintenant entrer la dernière valeur qui est votre poul du bras gauche (battement de coeur), c'est la plus petite des valeurs sur le tensiometre #{@customer.appelation}")
            query.send_message

          elsif @customer.steps == '521'

            @customer.updaye(poul_gauche: @body)
            @customer.update(steps: 8)

            sleep 1
            query = Whatsapp::WhatsappMessages.new(@phone, "super! Nous sommes presqu'a la fin. C'est possible que je puisse savoir dans quel quatier est ce que vous résidez #{@customer.appelation}?")
            query.send_message

          elsif @customer.steps == '8'
            @customer.update(quartier: @body)
            @customer.update(steps: 9)

            # prochaine question, le quartier
            sleep 1
            query = Whatsapp::WhatsappMessages.new(@phone, "Voila, je vous remerci *#{@customer.appelation}*, nous avons terminé.")
            query.send_message
            
            sleep 2
            query1 = Whatsapp::WhatsappMessages.new(@phone, "J'oubliais, le challenge continue *#{@customer.appelation}*, essaye de dépister d'autres personnes autour de toi, même dans ta *famille, collègues, ami(e)s, reunions* et  découvre quelque chose d'extraordinaire.")
            query1.send_message
          else
            sleep 1
            # send next message
            # message = Whatsapp::WhatsappMessages.new(@phone, "Bienveune dans le programme JE CONNAIS MA TENTSION, nous vous avons indentifier comme #{@name}")
            image = Whatsapp::WhatsappImages.new({phone: @phone, file: 'https://mppp-goshen.com/wp-content/uploads/2023/03/qrcode2.png', caption: "C'est terminé, vous vous êtes deja fait dépisté. Mais si vous souhaitez depister quelqu'un d'autre, saisir *autre* ou partager ce lien.\n shorturl.at/uCSW9"})
            image.send_image
            sleep 2
            query = Whatsapp::WhatsappMessages.new(@phone, "Votre lien de partage est le suivant shorturl.at/uCSW9, partagez-le afin de sauver des vies autour de vous.\n #{@customer.linked}")
            query.send_message
          end
        else
          # we have to save this customer in our DB
          customer = Customer.new(phone: @phone, pushname: @name, code: SecureRandom.hex(5))
          if customer.save
            # send message in return
            # message = Whatsapp::WhatsappMessages.new(@phone, "Bienveune dans le programme JE CONNAIS MA TENTSION, nous vous avons indentifier comme #{@name}")
            image = Whatsapp::WhatsappImages.new({phone: @phone, caption: "Bienvenue dans le challenge *JE CONNAIS MA TENSION*. Dont le thème est : Se *dépister et faire dépister les autres*"})
            image.send_image
            # message.send_message
            sleep 1
            query = Whatsapp::WhatsappMessages.new(@phone, "Notre challenge vise à ce que tout le monde autour de nous connaisse sa tension artérielle et ainsi réduire les cas d'AVC. Acceptes tu le challenge? Je suis *CARDIO* et c'est moi qui vais t'accompagner durant cette courte aventure.")
            query.send_message

            customer.update(steps: 1)
            
            sleep 2

            # on pose la prochaine question sur le nom et le prénom
            query1 = Whatsapp::WhatsappMessages.new(@phone, "Pour confirmer que tu accepte le challenge, comment je vous appelle?")
            query1.send_message
          else
            # send error messages
            puts customer.errors.details
          end
        end

      end

    else

      render json: {
        message: "Informations ou parametres manquand",
        status: 401
      }
    end
    
  end

  def salutation
    @instance = 'salutation'
    query = Whatsapp::WhatsappMessages.new(@phone, "Comment je vous appelle?")
    sleep 1
    query.send_message

    # update steps
    @customer.update(steps: 1)
  end

  def sexe 
  end

  def age 
  end

  def get_tension_first_value(value)
    # updaye step
    @customer.update(steps: 6)

    # tout va bien
    query = Whatsapp::WhatsappMessages.new(@phone, "#{sexe} #{@customer.real_name}, merci de nous fournir la première valeur, celle qui a un taille d'ecriture plus grande.")
    query.send_message
  end

  def get_tension_second_value(value)
    # read previous message before continue
    @customer.update(systol: @body)

    # updaye step
    @customer.update(steps: 6)

    # tout va bien
    query = Whatsapp::WhatsappMessages.new(@phone, "Merci, nous l'avons enregistrer, maintenan pouvez-vous nous donner la seconde valeur donné par votre tensiometre, juste en dessous de la première #{@customer.appelation}")
    query.send_message
  end

  def quartier 
    # read previous message before continue
    @customer.update(diatol: @body)

    # updaye step
    @customer.update(steps: 6)

    # tout va bien
    query = Whatsapp::WhatsappMessages.new(@phone, "Nous avons presque terminer, maintenant donnez nous la valeur du poul, je pense que c'est la plus petite des valeurs de votre tensiometre #{@customer.appelation}")
    query.send_message
  end

  def photo_link 
     # read previous message before continue
    @customer.update(poul: @body)

    # updaye step
    @customer.update(steps: 6)

    # tout va bien
    query = Whatsapp::WhatsappMessages.new(@phone, "Voilaaaaaa, nous pensons avoir toutes les informations, vous venez de reussir le challenge je connais ma tention #{@customer.appelation}")
    query.send_message
  end

  # module language
  # adding language analusis capabilities
  def get_lang
  end

end