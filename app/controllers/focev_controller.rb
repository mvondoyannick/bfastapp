class FocevController < ApiController
  # before_action :check_language

  def entry
    render json: { message: "hello" }
  end

  def index
    if (params["data"].present?)
      @instance = "none"
      puts params
      @body = params["data"]["body"]
      @image_type = params["data"]["type"]
      @image_path = params["data"]["media"]
      @name = params["data"]["pushname"]
      @phone = params["data"]["from"].delete("@c.us")

      if "autre".in? @body.downcase
        if Customer.exists?(phone: @phone)
          # get the customer
          @customer = Customer.find_by_phone(@phone)

          # make the query
          query = Whatsapp::WhatsappMessages.new(
            @phone, "Merci de nous faire confiance #{@customer.real_name}, vous avez demandé à effectuer un autre enrollement pour un tierce personne?"
          )
          query.send_message
        else
          # sorry
          query = Whatsapp::WhatsappMessages.new(
            @phone, "Merci mais nous ne retrouvons pas vos informations dans notre système!! Souhaitez-vous commencer par connaitre votre tension?"
          )
          query.send_message
        end
      elsif "end".in? @body.downcase
        q = Whatsapp::WhatsappMessages.new(
          @phone, "Vous avez terminé avec succès, merci de patienter."
        )
        q.send_message
      elsif "continuer".in? @body.downcase
        q = Whatsapp::WhatsappMessages.new(
          @phone, "Cette fonctionnalitée de rappel n'est pas encore implemntée, nous avons pris connaissance de votre relance."
        )
        q.send_message
      elsif "photo".in? @body.downcase
        q = Whatsapp::WhatsappMessages.new(
          @phone, "*Hey*, vous souhaitez soumettre votre photo pour participer au challenge *je connais ma tention*."
        )
        q.send_message
      elsif "ok".in? @body.downcase
        # ceci est une instance de rappel
        @customer.update(steps: "QT")
        q = Whatsapp::WhatsappMessages.new(
          @phone, "Nous avions un rappel dernièrement, et vous avez confirmer que ce rappel etait ce jour, nous allons donc continuer!"
        )
        sleep 1
        # check if customer have tools
        query0 = Whatsapp::WhatsappMessages.new(
          @phone, "Avez-vous un *tensiomètre* à votre disposition actuellement #{@customer.appelation}."
        )
        query0.send_message

        sleep 1
        a = Whatsapp::WhatsappMessages.new(
          @phone, "Saisir *A* si vous avez pris votre tension artérielle"
        )
        a.send_message

        sleep 1
        b = Whatsapp::WhatsappMessages.new(
          @phone, "Saisir *B* si vous allez le faire plus tard car ne disposant pas de tensiomètre"
        )
        b.send_message

        sleep 1
        c = Whatsapp::WhatsappMessages.new(
          @phone, "Saisir *C* pour savoir ce que c'est un *tensiomètre*"
        ) #https://fr.wikipedia.org/wiki/Tensiomètre #https://fr.wikihow.com/lire-sa-tension-artérielle-avec-un-tensiomètre
        c.send_message
      else
        # search this customer
        @customer = Customer.find_by_phone(@phone)
        if @customer
          @customer.update(ip: request.remote_ip)
          puts "il existe deja un customer, #{@customer.steps} on verifie les étapes deja franchis"
          if @customer.steps.nil?
          elsif @customer.steps == "1"
            # on enregistre le nom
            if @body.empty? || @body.nil?
              query = Whatsapp::WhatsappMessages.new(
                @phone, "Merci de renseigner votre nom, cela permettra de vous identifier durant tout le processus d'echange avec *CARDIO*"
              )
              query.send_message
            else
              @customer.update(real_name: @body)
              @customer.update(steps: 2)

              sleep 1
              # send next message
              query = Whatsapp::WhatsappMessages.new(
                @phone, "Merci *#{@customer.real_name.upcase}*, votre nom est original. Quel est votre sexe?"
              )
              query.send_message

              sleep 1
              masculin = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *M* pour Masculin 🙋🏽‍♂ "
              )

              masculin.send_message

              sleep 1
              feminin = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *F* pour Féminin 🙋🏽‍♀ "
              )

              feminin.send_message
            end
          elsif @customer.steps == "2"
            # on enregistre le sexe

            if %w[M F m f].include? @body
              @customer.update(sexe: @body)
              @customer.update(steps: 3)

              if (@body == "M" || @body == "m")
                @customer.update(sexe: "masculin")
              else
                @body == "F"
                @customer.update(sexe: "feminin")
              end

              # next question
              age = Whatsapp::WhatsappMessages.new(
                @phone, "Merci #{@customer.appelation}. Serait'il possible de connaitre votre *âge*?\n_Si vous avez 40 ans, il faudra juste ecrire *40*_"
              )
              age.send_message
            else
              # invalide sexe, try again
              query = Whatsapp::WhatsappImages.new(
                {
                  phone: @phone,
                  file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                  caption: "Merci de selectionner un sexe valide #{@customer.appelation}. Quel est votre sexe?.",
                }
              )
              query.send_image

              sleep 1
              masculin = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *M* pour Masculin 🙋🏽‍♂ "
              )

              masculin.send_message

              sleep 1
              feminin = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *F* pour Féminin 🙋🏽‍♀ "
              )

              feminin.send_message
            end

            # introduction de la taille
            # introduction du poids
          elsif @customer.steps == "poids"
            if (@body.to_i == 0)
              # le poids vari entre 30 et 250Kg
              @customer.update(poids: @body)
              @customer.update(steps: "taille")

              # next question
              taille = Whatsapp::WhatsappMessages.new(
                @phone, "Merci #{@customer.appelation}, Serait'il également possible d'avoir votre *taille*? #{@customer.appelation}\n_Si vous avez une taille de 1m59, ecrire juste *159*_\n\n_Si vous n'avez pas cette information, merci de mettre juste un *0*_"
              )
              taille.send_message
            elsif (30..250).member?(@body.to_i)
              # le poids vari entre 30 et 250Kg
              @customer.update(poids: @body)
              @customer.update(steps: "taille")

              # next question
              taille = Whatsapp::WhatsappMessages.new(
                @phone, "Merci #{@customer.appelation}, vous pesez #{@customer.poids}Kg. Serait'il également possible d'avoir votre *taille*? #{@customer.appelation}\n_Si vous avez une taille de 1m59, ecrire juste *159*_\n\n_Si vous n'avez pas cette information, merci de mettre juste un *0*_"
              )
              taille.send_message
            else
              query = Whatsapp::WhatsappImages.new(
                {
                  phone: @phone,
                  file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                  caption: "Humm #{@customer.appelation}, certainement mes lunèttes doivent être sale, mais là...je suis incapable de lire votre poids sur la balance, pouvez encore me donner de nouveau votre poids?\n_si vous avec 50Kg merci de saisir juste *50*_",
                }
              )
              query.send_image
            end
          elsif @customer.steps == "taille"
            if (@body.to_i == 0)

              # entre 1m et 2m50 de taille
              @customer.update(taille: @body)
              @customer.update(steps: "QT")

              sleep 1
              # send next message
              query = Whatsapp::WhatsappMessages.new(
                @phone, "Maintenant nous allons passer aux informations *médicales*, à savoir prendre votre tension arterielle #{@customer.appelation}. Mais avant nous souhaiterions nous rassurer d'une chose"
              )
              query.send_message

              # ====== other
              sleep 1
              # check if customer have tools
              query0 = Whatsapp::WhatsappMessages.new(
                @phone, "Avez-vous un *tensiomètre* à votre disposition actuellement #{@customer.appelation}."
              )
              query0.send_message

              sleep 1
              a = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *A* si vous avez pris votre tension artérielle"
              )
              a.send_message

              sleep 1
              b = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *B* si vous allez le faire plus tard car ne disposant pas de tensiomètre"
              )
              b.send_message

              sleep 1
              c = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *C* pour savoir ce que c'est un *tensiomètre*"
              ) #https://fr.wikipedia.org/wiki/Tensiomètre #https://fr.wikihow.com/lire-sa-tension-artérielle-avec-un-tensiomètre
              c.send_message
            elsif (100..250).member?(@body.to_i)
              # entre 1m et 2m50 de taille
              @customer.update(taille: @body)
              @customer.update(steps: "QT")

              sleep 1
              # send next message
              query = Whatsapp::WhatsappMessages.new(
                @phone, "Maintenant nous allons passer aux informations *médicales*, à savoir prendre votre tension arterielle #{@customer.appelation}. Mais avant nous souhaiterions nous rassurer d'une chose"
              )
              query.send_message

              # ====== other
              sleep 1
              # check if customer have tools
              query0 = Whatsapp::WhatsappMessages.new(
                @phone, "Avez-vous un *tensiomètre* à votre disposition actuellement #{@customer.appelation}."
              )
              query0.send_message

              sleep 1
              a = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *A* si vous avez pris votre tension artérielle"
              )
              a.send_message

              sleep 1
              b = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *B* si vous allez le faire plus tard car ne disposant pas de tensiomètre"
              )
              b.send_message

              sleep 1
              c = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *C* pour savoir ce que c'est un *tensiomètre*"
              ) #https://fr.wikipedia.org/wiki/Tensiomètre #https://fr.wikihow.com/lire-sa-tension-artérielle-avec-un-tensiomètre
              c.send_message
            else
              c = Whatsapp::WhatsappMessages.new(
                @phone, "J'ai quelque difficulté à lire votre taille ou alors la valeur saisie n'est pas correcte, pouvez vous la saisr de nouveau s'il vous plait."
              )
              c.send_message
            end
          elsif @customer.steps == "3"
            # @body.in?.between(18..100)
            @customer.update(age: @body)
            @customer.update(steps: "poids")

            # introduction de la taille
            sleep 1
            send_message(
              @phone, "Vous avez donc #{@customer.age} ans, serait-il egalement possible que je puisse avoir votre *poids* en Kilogramme #{@customer.appelation}\n_Si vous avez un poids de 70Kg vous allez simplement ecrire *70*_\n\n_Si vous n'avez pas cette information, mettez juste un *0*_"
            )
          elsif @customer.steps == "QT"
            @customer.update(question_tension: @body.downcase)

            if %w[a b c].include? @customer.question_tension
              case @customer.question_tension
              when "a"
                # il n'a pas de tensiometre
                @customer.update(steps: 4)

                # tout va bien
                img = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/04/sys.png",
                    caption: "OK #{@customer.appelation} merci de nous fournir la valeur du haut affichée sur le tensiometre placé sur votre bras droit *(SYS)*. \n_Celle encadrée en rouge, mais sur votre tensiomètre_",
                  }
                )
                img.send_image
              when "b"
                @customer.update(steps: "no_tension")
                # il ya un probleme, merci de fournir le bras gauche
                no = Whatsapp::WhatsappMessages.new(
                  @phone, "Hum, vous semblez ne pas avoir de tensiometre sous la main. Pourrions nous vous revenir suivant les options que proposées? #{@customer.appelation}?"
                )
                no.send_message

                sleep 1
                d = Whatsapp::WhatsappMessages.new(
                  @phone, "Saisir 1 Pour être rappelé(e) dans 24h *(demain)*" # get the next day in french
                )
                d.send_message

                sleep 1
                c = Whatsapp::WhatsappMessages.new(
                  @phone, "Saisir 2 Pour être rappelé(e) dans 72h *(3 jours)*" # the new 3 day in frech with some date
                )
                c.send_message

                sleep 1
                e = Whatsapp::WhatsappMessages.new(
                  @phone, "Saisir 3 Pour être rappelé(e) dans *5 jours*" # the new day appelation in french"
                )
                e.send_message

                sleep 1
                f = Whatsapp::WhatsappMessages.new(
                  @phone, "Saisir 4 Laissez moi un peu de temps, je vous reviendrais."
                )
                f.send_message
              when "c"
                # il veut en apprendre plus

                query =
                  Whatsapp::WhatsappMessages.new(
                    @phone, "Vous souhaitez en apprendre plus sur le tensiomètre, nous avons deux articles pour vous #{@customer.appelation}."
                  )
                query.send_message

                sleep 1
                wiki = Whatsapp::WhatsappMessages.new(
                  @phone, "*Wikipedia* nous présente le tensiometre \n\nhttps://fr.wikipedia.org/wiki/Tensiomètre"
                )
                wiki.send_message

                sleep 1
                pedia = Whatsapp::WhatsappMessages.new(
                  @phone, "*WikiHow* pour apprend comment lire un tensiomètre \n\nhttps://fr.wikihow.com/lire-sa-tension-artérielle-avec-un-tensiomètre"
                )
                pedia.send_message

                sleep 2
                # check if customer have tools
                query0a = Whatsapp::WhatsappMessages.new(
                  @phone, "Avez-vous un *tensiomètre* à votre disposition actuellement #{@customer.appelation}."
                )
                query0a.send_message

                sleep 1
                a1 = Whatsapp::WhatsappMessages.new(
                  @phone, "Saisir *A* si vous avez pris votre tension artérielle"
                )
                a1.send_message

                sleep 1
                b2 = Whatsapp::WhatsappMessages.new(
                  @phone, "Saisir *B* si vous allez le faire plus tard car ne disposant pas de tensiomètre"
                )
                b2.send_message
              else
              end
            else
              @customer.update(steps: "QT")

              sleep 1
              qt = Whatsapp::WhatsappMessages.new(
                @phone, "Les valeurs fournis ne sont pas celles attendues, merci de choisir parmi les valeurs proposées. \n\nAvez-vous un *tensiomètre* à votre disposition actuellement #{@customer.appelation}."
              )
              qt.send_message

              sleep 1
              a = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *A* si vous avez pris votre tension artérielle"
              )
              a.send_message

              sleep 1
              b = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *B* si vous allez le faire plus tard car ne disposant pas de tensiomètre"
              )
              b.send_message

              sleep 1
              c = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *C* pour savoir ce que c'est un *tensiomètre*"
              ) #https://fr.wikipedia.org/wiki/Tensiomètre #https://fr.wikihow.com/lire-sa-tension-artérielle-avec-un-tensiomètre
              c.send_message
            end
          elsif @customer.steps == "no_tension"
            @customer.update(rappel: @body)
            @customer.update(steps: "need_rappel")

            # make date calculation
            # the next 24 hours
            @customer.date_rappel = DateTime.now + @customer.rappel.to_i.day

            @customer.update(rappel_day: @body)

            sleep 1
            if Date.today.monday?
              message = "Passez un bon debut de semaine"
            elsif Date.today.friday?
              message = "Passez un bon debut de weekend"
            else
              message = "Passez une bonne semaine"
            end

            text =
              Whatsapp::WhatsappMessages.new(
                @phone, "Merci, nous allons vous revenir dans un delais de #{@customer.rappel} jour(s). #{message}. \n\nPensez à visiter le site de la *Fondation Coeur et Vie* à l'adresse \nwww.coeur-vie.org"
              )
            text.send_message
          elsif @customer.steps == "need_rappel"
            text = Whatsapp::WhatsappMessages.new(
              @phone, "Hello #{@customer.real_name}, notre rappel à lieu le *#{@customer.date_rappel}* jour(s), nous vous relancerons dans ces delais. Si par contre vous disposez deja vos parametres de tension, merci de saisir *continuer*."
            )
            text.send_message
          elsif @customer.steps == "4"
            # lecture systole
            @customer.update(tension_droit: @body)
            @customer.update(steps: 5)

            query = Whatsapp::WhatsappMessages.new(
              @phone, "Merci, nous avons enregistré cette valeur comme votre systole, maintenant merci de nous fournir votre diastole du même bras #{@customer.appelation}."
            )

            img = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "https://mppp-goshen.com/wp-content/uploads/2023/04/dia.png",
                caption: "Merci, cette valeur de *#{@customer.tension_droit}* a été enregistré. Maintenant nous aurons besoin que vous nous fournissiez la valeur situé au milieu de votre tensiometre placé toujours sur votre bras droit *(DIA)*. \n_Celle encadrée en rouge, mais sur votre tensiomètre_",
              }
            )
            img.send_image
          elsif @customer.steps == "51"
            # read diastole droit
            @customer.update(diastole_droit: @body)
            @customer.update(steps: 52)

            sleep 1
            query = Whatsapp::WhatsappMessages.new(
              @phone, "super, c'est enregistré, maintenant entrer la dernière valeur qui est votre poul du bras droit (battement de coeur), c'est la plus petite des valeurs sur le tensiometre #{@customer.appelation}"
            )
            query.send_message
          elsif @customer.steps == "52"
            # read diastole droit
            @customer.update(poul_droit: @body)
            @customer.update(steps: 8)

            sleep 1
            query =
              Whatsapp::WhatsappMessages.new(
                @phone,
                "super! Nous sommes presqu'a la fin. C'est possible que je puisse savoir dans quel quartier est ce que vous résidez #{@customer.appelation}?"
              )
            query.send_message
          elsif @customer.steps == "5"
            # lecture de pool gauche
            @customer.update(diastole_droit: @body)
            @customer.update(steps: "5D") # pour etape 5 bras droit

            sleep 1
            img =
              Whatsapp::WhatsappImages.new(
                {
                  phone: @phone,
                  file: "https://mppp-goshen.com/wp-content/uploads/2023/04/pulse.png",
                  caption: "Merci, cette valeur de *#{@customer.diastole_droit}* a été enregistré. \nMaintenant nous aurons besoin que vous nous fournissiez la dernière valeur située en dernière position de votre tensiometre placé toujours sur votre bras droit *(PULSE)*. \n_Celle encadrée en rouge, mais sur votre tensiomètre_",
                }
              )
            img.send_image
          elsif @customer.steps == "5D"
            @customer.update(poul_droit: @body)

            # condition
            case @customer.tension_droit.to_i
            when 0..90
              # de toute façon il doit refaire
              @customer.update(steps: "5G")

              sleep 1
              query = Whatsapp::WhatsappMessages.new(
                @phone, "Hummm...Nous avons du mal à analyser vos résultats. Pouvez vous nous fournir (pour confirmation) nous avons besoin de plus d'informations sur la tension de votre bras gauche. \n_Merci de placer le tensiomètre sur votre bras gauche #{@customer.appelation}._"
              )
              query.send_message
              sleep 1
              img = Whatsapp::WhatsappImages.new(
                {
                  phone: @phone,
                  file: "https://mppp-goshen.com/wp-content/uploads/2023/04/sys.png",
                  caption: "Merci de fournir la valeur situé au plus haut de votre tensiometre placé sur votre bras gauche. *(SYS)*. \n_Celle encadrée en rouge, mais sur votre tensiomètre_",
                }
              )
              img.send_image
            when 60..90
              @customer.update(steps: "5Q")
              # il ya un probleme, merci de fournir le bras gauche
              sleep 1
              query = Whatsapp::WhatsappMessages.new(
                @phone, "super! nous sommes presque à la fin. \nC'est possible que je puisse savoir dans quel quatier est ce que vous résidez #{@customer.appelation}. \n_Merci de fournir la ville et le quartier comme Maroua, Domayo ou Douala, Ndokoti_"
              )
              query.send_message
            when 90..300
              # c'est grave, consulter à l'immédiat
              @customer.update(steps: "5Q")
              sleep 1
              query = Whatsapp::WhatsappMessages.new(
                @phone, "super! nous sommes presque à la fin. \nC'est possible que je puisse savoir dans quel quatier est ce que vous résidez #{@customer.appelation}. \n_Merci de fournir la ville et le quartier comme Maroua, Domayo ou Douala, Ndokoti_"
              )
              query.send_message
            end
          elsif @customer.steps == "5Q" #pour quartier
            @customer.update(quartier: @body)
            @customer.update(steps: "challenge") # get user photos challenge

            q = Whatsapp::WhatsappMessages.new(
              @phone, "Vous avez terminé. \n\nNous avons un challenge qui concerne à mettre sur votre status *WhatsApp* votre photo de profile (personnalisée). \nQu'est ce que vous en pensez #{@customer.appelation}?"
            )
            q.send_message

            sleep 1
            q = Whatsapp::WhatsappMessages.new(
              @phone, "Saisir *A* si vous êtes interessé et souaitez nous envoyer votre photo de profile"
            )
            q.send_message

            sleep 1
            p1 = Whatsapp::WhatsappMessages.new(
              @phone, "Saisir *NON* si nous n'etes pas intéressé(e)."
            )
            p1.send_message
          elsif @customer.steps == "challenge"
            if %w[A a B b NON non Non].include? @body.downcase
              case @body
              when "A"
                @customer.update(steps: "send_photo_ok")

                photo = Whatsapp::WhatsappMessages.new(
                  @phone, "Merci de nous fournir une photo de votre visage.\n\n*NB:* _Toutes photos autre que celle de votre visage sera rejetée._"
                )
                photo.send_message
              when "NON"
                @customer.update(steps: "send_photo_ko")

                query = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                    caption: "Merci de votre réponse. Retouvez toutes les informations sur le challenge  *Je connais ma tension* sur les réseaux à l'adresse \nhttps://www.facebook.com/profile.php?id=100090307216315.",
                  }
                )
                query.send_image

                sleep 2

                photo = Whatsapp::WhatsappMessages.new(
                  @phone, "Ah j'oubliais ... \nTu peux partager ton lien et inviter egalement d'autres personnes à participer au challenge ...devient un ambassadeur en partageant ton lien et fais toi l'ambassadeur des *ambassadeurs* ton lien \n\nLe tien est #{@customer.linked}"
                )
                photo.send_message
              end
            else
              q = Whatsapp::WhatsappMessages.new(
                @phone, "Les reponses attendues ne sont pas valides, merci de réessayer #{@customer.appelation}"
              )
              q.send_message

              sleep 1
              q1 = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *A* si vous êtes interessé et souaitez nous envoyer votre photo de profile"
              )
              q1.send_message

              sleep 1
              p1 = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *NON* si nous n'etes pas intéressé(e)."
              )
              p1.send_message
            end
          elsif @customer.steps == "send_photo_ok"
            @customer.update(photo: @image_path)

            @down = Down.download(@image_path)
            FileUtils.mv(@down.path, "#{@customer.phone}.jpg")

            query = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                caption: "Votre image a été enregistrée! Le traitement prendra quelque secondes, mais vous serez notifié dès que le montage sera disponible.",
              }
            )
            query.send_image

            sleep 2

            # configuration
            Cloudinary.config do |config|
              config.cloud_name = "diqsvucdn"
              config.api_key = "127829381549272"
              config.api_secret = "Bv9KguwYaSSr3BtcNuhCU2YpE84"
              config.secure = true
            end

            Cloudinary::Uploader.upload @image_path, public_id: @customer.phone

            @cloudinary_image_url = Cloudinary::Utils.cloudinary_url(
              @customer.phone,
              gravity: "face",
              width: 200,
              height: 200,
              crop: "thumb",
            )

            # attache it to customer
            @face_init = Down.download(@cloudinary_image_url)
            FileUtils.mv(@face_init.path, "face_#{@customer.phone}.png")

            #call remove.bg
            RemoveBg.configure do |config|
              config.api_key = "Qp7kGiHaf2KSuhhEXAz3YMav"
            end
            removebg = RemoveBg.from_file("face_#{@customer.phone}.png")
            removebg.save("face_#{@customer.phone}.png", overwrite: true)

            @image_face = File.open("face_#{@customer.phone}.png")
            @customer.face.attach(
              io: @image_face,
              filename: "face_#{@customer.phone}.png",
              content_type: "image/jpg",
            )

            first_image = MiniMagick::Image.open(
              "http://coeur-vie.org/wp-content/uploads/2023/06/challenge-1_new.jpg"
            )
            second_image = MiniMagick::Image.open(@image_face)
            result = first_image.composite(second_image) do |c|
              c.compose "Over" # OverCompositeOp
              c.geometry "+340+200" # copy second_image onto first_image from (20, 20)
            end
            @tmp_name = SecureRandom.hex(10)

            result.write "challenge_#{@customer.phone}.jpg"

            # reimport this image
            finale_challenge = MiniMagick::Image.open("challenge_#{@customer.phone}.jpg")
            finale_challenge.combine_options do |c|
              c.font "helvetica"
              c.fill "white"
              c.pointsize 20
              c.gravity "center"
              c.draw "text 150,160 '#{@customer.real_name}'"
            end

            finale_challenge.write "challenge_#{@customer.phone}.jpg"

            # attache challenge
            @image_challenge = File.open("challenge_#{@customer.phone}.jpg")
            @customer.challenge.attach(
              io: @image_challenge,
              filename: "challenge_#{@customer.phone}.jpg",
              content_type: "image/jpg",
            )

            # send notification
            image_wa = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(@customer.challenge, only_path: true)}",
                caption: "Votre photo challenge est disponible #{@customer.appelation}, merci de la partager sur votre photo de profile. \nSaviez-vous que vous pouvez également partager ce lien et sauver des vies autour de vous? Juste en partageant votre lien d'ambassadeur \n\n #{@customer.linked}",
              }
            )
            image_wa.send_image

            sleep 1
            linked = Whatsapp::WhatsappMessages.new(
              @phone,
              "#{@customer.appelation}, nous pensons que votre engagement cache un désire plus grand...celui d'etre *embassadeur* du programme. Votre lien de partage *ambassadeur* est le suivant \n\n#{@customer.linked} \nPartagez le autour de toi, dans ta famille, sur les réseaux sociaux, parmis tes collègues...sauvez des vies."
            )
            linked.send_message
          elsif @customer.steps == "send_photo_ko"
            @customer.update(step: "end")

            p1 = Whatsapp::WhatsappMessages.new(
              @phone,
              "Merci, vous avez terminé."
            )
            p1.send_message
          elsif @customer.steps == "5G"
            # mesure des valeurs du bras gauche
            @customer.updaye(tension_gauche: @body)
            @customer.update(steps: "5DG") # systole gauche

            query = Whatsapp::WhatsappMessages.new(
              @phone,
              "super, maintenant donnez nous egalement la diastole de votre bras gauche #{@customer.appelation}"
            )
            query.send_message
          elsif @customer.steps == "5DG"
            # mesure des valeurs diastole du bras gauche
            @customer.updaye(tension_gauche: @body)
            @customer.update(steps: "5PG") # poule gauche

            query = Whatsapp::WhatsappMessages.new(
              @phone,
              "super, maintenant il ne nous reste que le poul, et puis on aura terminé #{@customer.appelation}, nous sommes preque à la fin"
            )
            query.send_message
          elsif @customer.steps == "5PG"
            @customer.updaye(poul_gauche: @body)
            @customer.update(steps: 8) # poule gauche

            query = Whatsapp::WhatsappMessages.new(
              @phone,
              "super! Nous y sommes, j'aimerais juste savoir dans quel quartier vous habitez? #{@customer.appelation}"
            )
            query.send_message
          elsif @customer.steps == "511"
            @customer.updaye(diastole_gauche: @body)
            @customer.update(steps: 521)

            sleep 1
            query = Whatsapp::WhatsappMessages.new(
              @phone, "super, c'est enregistré, maintenant entrez la dernière valeur qui est votre poul du bras gauche (battement de coeur), c'est la plus petite des valeurs sur le tensiometre #{@customer.appelation}"
            )
            query.send_message
          elsif @customer.steps == "521"
            @customer.updaye(poul_gauche: @body)
            @customer.update(steps: 8)

            sleep 1
            query = Whatsapp::WhatsappMessages.new(
              @phone, "super! Nous sommes presqu'a la fin. C'est possible que je puisse savoir dans quel quartier est ce que vous résidez #{@customer.appelation}?"
            )
            query.send_message
          elsif @customer.steps == "8"
            @customer.update(quartier: @body)
            @customer.update(steps: 9)

            # prochaine question, le quartier
            sleep 1
            query = Whatsapp::WhatsappMessages.new(
              @phone, "Voila, je vous remerci #{@customer.appelation}, nous avons terminé."
            )
            query.send_message

            sleep 2
            query1 = Whatsapp::WhatsappMessages.new(
              @phone, "J'oubliais, le challenge continue #{@customer.appelation}, essaye de dépister d'autres personnes autour de toi, même dans ta *famille, collègues, ami(e)s, reunions* et  découvre quelque chose d'extraordinaire."
            )
            query1.send_message
          else
            sleep 1
            # send next message
            # message = Whatsapp::WhatsappMessages.new(@phone, "Bienveune dans le programme JE CONNAIS MA TENTSION, nous vous avons indentifier comme #{@name}")
            image = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "https://mppp-goshen.com/wp-content/uploads/2023/03/qrcode2.png",
                caption: "C'est terminé, vous vous êtes deja fait dépisté. Mais si vous souhaitez depister quelqu'un d'autre, saisir *autre* ou partager ce lien.\n #{@customer.linked}",
              }
            )
            image.send_image
            sleep 2
            query = Whatsapp::WhatsappMessages.new(
              @phone, "Votre lien de partage est le suivant #{@customer.linked}, partagez-le afin de sauver des vies autour de vous.\n #{@customer.linked}"
            )
            query.send_message
          end
        else
          # we have to save this customer in our DB
          customer = Customer.new(
            phone: @phone,
            pushname: @name,
            code: SecureRandom.hex(5),
          )
          if customer.save
            # send message in return
            # message = Whatsapp::WhatsappMessages.new(@phone, "Bienveune dans le programme JE CONNAIS MA TENTSION, nous vous avons indentifier comme #{@name}")
            image = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "http://coeur-vie.org/wp-content/uploads/2023/06/WhatsApp-Image-2023-06-06-a-11.40.55.jpg",
                caption: "Bienvenue dans le challenge *JE CONNAIS MA TENSION*. Dont le thème est : Se *dépister et faire dépister les autres*",
              }
            )
            image.send_image
            # message.send_message
            sleep 1
            query = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                caption: "Notre challenge vise à ce que tout le monde autour de nous connaisse sa tension artérielle et ainsi réduire les cas d'AVC. Acceptes tu le challenge? \nJe suis le Dr *CARDIO* de la Fondation Coeur et Vie et c'est moi qui vais t'accompagner durant cette courte aventure.",
              }
            )
            query.send_image

            customer.update(steps: 1)

            sleep 2

            # on pose la prochaine question sur le nom et le prénom
            query1 = Whatsapp::WhatsappMessages.new(
              @phone, "Pour confirmer que vous acceptez le *challenge*, comment je vous appelle?\n\n_En acceptant le challenge *Je Connais ma Tension* vous acceptez les regles de confidentialités disponibles sur notre site web http://coeur-vie.org/privacy_"
            )
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
               status: 401,
             }
    end
  end

  def chatbot
    if (params["data"].present?)
      @instance = "none"
      puts params
      @body = params["data"]["body"]
      @image_type = params["data"]["type"]
      @image_path = params["data"]["media"]
      @name = params["data"]["pushname"]
      @phone = params["data"]["from"].delete("@c.us")

      @customer = Customer.find_by_phone(@phone)
      if @customer
        puts "customer found as #{@customer.pushname}"

        if @customer.steps == "select_language"
          puts "#{@customer.pushname} has to define language"
          if %w[A B].include? @body
            case @body
            when "A" #francais
              @customer.update(lang: "fr")
            when "B" #Anglais
              @customer.update(lang: "en")
            else
              puts "Impossible de continuer"
            end

            # next question with lang as condition
            case @customer.lang
            when "fr"
              welcome_fr

              # get name
              @customer.update(steps: "request_name")
            when "en"
              welcome_en

              # get name
              @customer.update(steps: "request_name")
            else
              # selectionner de nouveau la langue

              request_language

              @customer.update(steps: "select_language")
            end
          else
            a = Whatsapp::WhatsappMessages.new(
              @phone, "Les valeurs choisies ne sont pas correctes, merci de modifier et de réessayer"
            )
            a.send_message

            sleep 2
            query = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "http://coeur-vie.org/wp-content/uploads/2023/06/translate.png",
                caption: "*Bonjour!* Veillez selectionner votre langue de conversation\n\n_*Hello!* Please select your conversation language_",
              }
            )
            query.send_image

            sleep 1

            a = Whatsapp::WhatsappMessages.new(
              @phone, "Saisir *A* pour le 🇫🇷 FRANCAIS \n====\n_Type *A* for 🇫🇷 FRENCH_"
            )
            a.send_message

            b = Whatsapp::WhatsappMessages.new(
              @phone, "Saisir *B* pour 🇬🇧 l'ANGLAIS \n====\n_Type *B* for 🇬🇧 ENGLISH_"
            )
            b.send_message

            @customer.update(steps: "select_language")
          end
        elsif @customer.steps == "request_name"
          if @body.index(/[^[:alnum:]]/).nil?
            # save this information
            @customer.update(real_name: @body)

            case @customer.lang
            when "fr"
              request_sexe_fr
            when "en"
              request_sexe_en
            end

            @customer.update(steps: "request_sexe")
          else
            a = Whatsapp::WhatsappMessages.new(
              @phone, "Il semblerait que *#{@body}* ne soit pas un nom valide, merci de saisir un nom valide"
            )
            a.send_message
            @customer.update(steps: "request_name")
          end
        elsif @customer.steps == "request_sexe"
          if %w[A B].include? @body
            case @body
            when "A"
              @customer.update(sexe: "masculin")
            when "B"
              @customer.update(sexe: "feminin")
            end

            # next question about age
            case @customer.lang
            when "fr"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "Merci #{@customer.appelation}. Serait'il possible de connaitre votre *âge*?\n_Si vous avez 40 ans, il faudra juste ecrire *40*_"
              )
              age.send_message
            when "en"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "Thanks #{@customer.appelation}. Would it be possible to know your *age*?\n_If you are 40, just write *40*_"
              )
              age.send_message
            end
            @customer.update(steps: "request_age")
          else
            case @customer.lang
            when "fr"
            when "en"
            end
          end
        elsif @customer.steps == "request_age"
          if (15..100).include? @body.to_i
            @customer.update(age: @body)
            case @customer.lang
            when "fr"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "Vous avez donc *#{@customer.age}* ans #{@customer.appelation}, dans la même lancée, serait-il également possible que je puisse avoir votre poids en Kilogramme?\n\n_Si vous avez un poinds de 70Kg vous allez simplement ecrire *70*. Si vous n'avez pas cette information, saisir *0* (zero)_"
              )
              age.send_message
            when "en"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "So you have *#{@customer.age}* years #{@customer.appelation}, in the same vein, would it also be possible for me to have your weight in Kilograms?\n\n_If you have a weight of 70Kg you will simply write *70*. If you do not have this information, enter *0* (zero)_"
              )
              age.send_message
            end
            @customer.update(steps: "request_poids")
          else
            case @customer.lang
            when "fr"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "Je n'arrive pas correctement à determiner votre âge, merci de saisir de nouveau votre age #{@customer.appelation}.\n\n_Si vous avez 20 ans, saisir seulement *20*_"
              )
              age.send_message
            when "en"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "I can't correctly determine your age, please enter your age again #{@customer.appelation}.\n\n_If you are 20 years old, enter only *20*_"
              )
              age.send_message
            end

            @customer.update(steps: "request_age")
          end
        elsif @customer.steps == "request_poids"
          if (12..400).include? @body.to_i
            @customer.update(poids: @body)
            case @customer.lang
            when "fr"
              taille = Whatsapp::WhatsappMessages.new(
                @phone, "Merci #{@customer.appelation}, Serait'il également possible d'avoir votre *taille*? #{@customer.appelation}\n_Si vous avez une taille de 1m59, ecrire juste *159*_\n\n_Si vous n'avez pas cette information, merci de mettre juste un *0*_"
              )
              taille.send_message
            when "en"
              taille = Whatsapp::WhatsappMessages.new(
                @phone, "Thanks #{@customer.appelation}, Would it also be possible to have your *size*? #{@customer.appelation}\n_If you are 1m59 tall, just write *159*_\n\n_If you don't have this information, please just put a *0*_"
              )
              taille.send_message
            end
            @customer.update(steps: "request_taille")
          else
            case @customer.lang
            when "fr"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "Je n'arrive pas correctement à determiner votre poids, merci de saisir de nouveau votre poids #{@customer.appelation}.\n\n_Si vous avez 75Kg ans, saisir seulement *75*_"
              )
              age.send_message
            when "en"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "I can't correctly determine your weight, please enter your weight again #{@customer.appelation}.\n\n_If you are 75 Kg old, enter only *75*_"
              )
              age.send_message
            end

            @customer.update(steps: "request_poids")
          end
        elsif @customer.steps == "request_taille"
          if (50..250).include? @body.to_i
            @customer.update(taille: @body)
            case @customer.lang
            when "fr"
              request_tensiometre_fr
            when "en"
              request_tensiometre_en
            end
            customer.update(steps: "request_tension")
          else
            case @customer.lang
            when "fr"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "Je n'arrive pas correctement à determiner votre taille, merci de saisir de nouveau votre taille #{@customer.appelation}.\n\n_Si vous avez 1m75, saisir seulement *175*, si vous avez 1m, saisir *100*_"
              )
              age.send_message
            when "en"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "I can't correctly determine your height, please enter your height again #{@customer.appelation}.\n\n_If you are 1m75 height, enter only *175*, else if you have 1m, juste type *100*_"
              )
              age.send_message
            end

            @customer.update(steps: "request_taille")
          end
        elsif @customer.steps == "request_tension"
          if %w[A B C].include? @body
            case @customer.lang
            when "fr"
              case @body
              when "A"
                # j'ai un tensiometre
                img = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/04/sys.png",
                    caption: "OK #{@customer.appelation} merci de nous fournir la valeur du haut affichée sur le tensiometre placé sur votre bras droit *(SYS)*. \n_Celle encadrée en rouge, mais sur votre tensiomètre_",
                  }
                )
                img.send_image

                # read systole
                @customer.update(steps: "read_systole")
              when "B"
                no = Whatsapp::WhatsappMessages.new(
                  @phone, "Vous ne semblez pas avoir de tensiomètre à portée de main. Pourrions-nous revenir vers vous selon les options proposées ? #{@customer.appelation}?"
                )
                no.send_message

                sleep 1
                d = Whatsapp::WhatsappMessages.new(
                  @phone, "Entrez *1* Pour être rappelé dans 24h *(demain)*" # get the next day in french
                )
                d.send_message

                sleep 1
                c = Whatsapp::WhatsappMessages.new(
                  @phone, "Entrez *2* Pour être rappelé sous 72h *(3 jours)*" # the new 3 day in frech with some date
                )
                c.send_message

                sleep 1
                e = Whatsapp::WhatsappMessages.new(
                  @phone, "Entrez *3* Pour être rappelé dans *5 jours*" # the new day appelation in french"
                )
                e.send_message

                sleep 1
                f = Whatsapp::WhatsappMessages.new(
                  @phone, "Entrez *4* pour me donner un peu de temps, je vous recontacterai."
                )
                f.send_message

                @customer.update(steps: "read_rappel")
              when "C"
                query =
                  Whatsapp::WhatsappMessages.new(
                    @phone, "Vous souhaitez en savoir plus sur le tensiomètre, nous avons deux articles pour vous #{@customer.appelation}."
                  )
                query.send_message

                sleep 1
                wiki = Whatsapp::WhatsappMessages.new(
                  @phone, "*Wikipedia* nous présente le tensiomètre \n\nhttps://fr.wikipedia.org/wiki/Tensiomètre"
                )
                wiki.send_message

                sleep 1
                pedia = Whatsapp::WhatsappMessages.new(
                  @phone, "*WikiHow* pour apprendre à lire un tensiomètre \n\nhttps://fr.wikihow.com/lire-sa-tension-artérielle-avec-un-tensiomètre"
                )
                pedia.send_message
              end
            when "en"
              case @body
              when "A"
                img = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/04/sys.png",
                    caption: "OK #{@customer.appelation} please provide us with the top value displayed on the blood pressure monitor placed on your right arm *(SYS)*. \n_The one framed in red, but on your blood pressure monitor_",
                  }
                )
                img.send_image
                @customer.update(steps: "read_systole")
              when "B"
                no = Whatsapp::WhatsappMessages.new(
                  @phone, "Um, you don't seem to have a blood pressure monitor handy. Could we get back to you according to the options offered? #{@customer.appelation}?"
                )
                no.send_message

                sleep 1
                d = Whatsapp::WhatsappMessages.new(
                  @phone, "Enter *1* To be called back in 24 hours *(tomorrow)*" # get the next day in french
                )
                d.send_message

                sleep 1
                c = Whatsapp::WhatsappMessages.new(
                  @phone, "Enter *2* To be called back within 72 hours *(3 days)*" # the new 3 day in frech with some date
                )
                c.send_message

                sleep 1
                e = Whatsapp::WhatsappMessages.new(
                  @phone, "Enter *3* To be called back in *5 days*" # the new day appelation in french"
                )
                e.send_message

                sleep 1
                f = Whatsapp::WhatsappMessages.new(
                  @phone, "Enter *4* to give me some time, I'll get back to you."
                )
                f.send_message

                @customer.update(steps: "read_rappel")
              when "C"
                query =
                  Whatsapp::WhatsappMessages.new(
                    @phone, "You want to learn more about the blood pressure monitor, we have two articles for you #{@customer.appelation}."
                  )
                query.send_message

                sleep 1
                wiki = Whatsapp::WhatsappMessages.new(
                  @phone, "*Wikipedia* introduces us to the blood pressure monitor \n\nhttps://en.wikipedia.org/wiki/Sphygmomanometer"
                )
                wiki.send_message

                sleep 1
                pedia = Whatsapp::WhatsappMessages.new(
                  @phone, "*WikiHow* to learn how to read a blood pressure monitor \n\nhttps://fr.wikihow.com/lire-sa-tension-artérielle-avec-un-tensiomètre"
                )
                pedia.send_message
              else
              end
            end
          else
            case @customer.lang
            when "fr"
              request_tensiometre_fr
            when "en"
              request_tensiometre_en
            end
            @customer.update(steps: "request_tension")
          end
        elsif @customer.steps == "read_rappel"
          if %w[1 2 3 4].include? @body
            @customer.settings.last.update(
              rappel_day: @body.to_i,
              date_rappel: DateTime.now + @body.to_i.day,
            )

            sleep 1
            if Date.today.monday?
              message = "Passez un bon debut de semaine"
            elsif Date.today.friday?
              message = "Passez un bon debut de weekend"
            else
              message = "Passez une bonne semaine"
            end

            text = Whatsapp::WhatsappMessages.new(
              @phone, "Merci, nous allons vous revenir dans un delais de #{@customer.rappel} jour(s). #{message}. \n\nPensez à visiter le site de la *Fondation Coeur et Vie* à l'adresse \nwww.coeur-vie.org"
            )
            text.send_message
          else
            case @customer.lang
            when "fr"
              # relaunche selection choice
              q = Whatsapp::WhatsappMessages.new(
                @phone, "Je n'ai pas bien compris votre choix, pouvez-vous encore répondre #{@customer.appelation}?"
              )
              q.send_message
            when "en"
              # relaunche selection choice
              q = Whatsapp::WhatsappMessages.new(
                @phone, "I did not quite understand your choice, can you still answer #{@customer.appelation}?"
              )
              q.send_message
            end
          end
        elsif @customer.steps == "read_systole"
          if (@body.length > 3) || (@body.to_i == 0)
            case @customer.lang
            when "fr"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "Je pense qu'il doit avoir un petit problème avec ce que vous avez ecris, essayer de modifier et de recommencer.\n\n_Inserer uniquement une valeur à la fois, si votre valeur est *118*, inserer uniquement *118*_"
              )
              age.send_message
            when "en"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "I think there must be a little problem with what you wrote, try to modify and start again.\n\n_Insert only one value at a time, if your value is *118*, insert only *118*_"
              )
              age.send_message
            end
            @customer.update(steps: "read_systole")
          else
            @settings = @customer.settings.new(
              tension_droite: @body,
            )
            if @settings.save
              case @customer.lang
              when "fr"
                img = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/04/dia.png",
                    caption: "Merci, cette valeur de *#{@customer.settings.last.tension_droite}* a été enregistré. Maintenant nous aurons besoin que vous nous fournissiez la valeur situé au milieu de votre tensiometre placé toujours sur votre bras droit *(DIA)*. \n_Celle encadrée en rouge, mais sur votre tensiomètre_",
                  }
                )
                img.send_image
                @customer.update(steps: "read_diastole")
              when "en"
                img = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/04/dia.png",
                    caption: "Thank you, this value of *#{@customer.settings.last.tension_droite}* has been registered. Now we will need you to provide us with the value located in the middle of your blood pressure monitor placed always on your right arm *(DIA)*. \n_The one framed in red, but on your blood pressure monitor_",
                  }
                )
                img.send_image
                @customer.update(steps: "read_diastole")
              end
            else
              # creation of error logs
              @erreur = Erreur.new(
                description: @settings.errors.message,
                customer_id: @customer.id,
              )
              @erreur.save
            end
          end
        elsif @customer.steps == "read_diastole"
          if (@body.length > 3) || (@body.to_i == 0)
            case @customer.lang
            when "fr"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "Je pense qu'il doit avoir un petit problème avec ce que vous avez ecris, essayer de modifier et de recommencer.\n\n_Inserer uniquement une valeur à la fois, si la veuleur que vous souhaitez inserer est *118*, inserer uniquement *118*_"
              )
              age.send_message
            when "en"
              age = Whatsapp::WhatsappMessages.new(
                @phone, "I think there must be a little problem with what you wrote, try to modify and start again.\n\n_Insert only one value at a time, if your value is *118*, insert only *118*_"
              )
              age.send_message
            end
            @customer.update(steps: "read_diastole")
          else
            @settings = @customer.settings.last.update(
              diastole_droit: @body,
            )
            if @settings
              case @customer.lang
              when "fr"
                img = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/04/pulse.png",
                    caption: "Merci, cette valeur de *#{@customer.settings.last.diastole_droit}* a été enregistré. \nMaintenant nous aurons besoin que vous nous fournissiez la dernière valeur située en dernière position de votre tensiometre placé toujours sur votre bras droit *(PULSE)*. \n_Celle encadrée en rouge, mais sur votre tensiomètre_",
                  }
                )
                img.send_image
                @customer.update(steps: "read_poul")
              when "en"
                img =
                  Whatsapp::WhatsappImages.new(
                    {
                      phone: @phone,
                      file: "https://mppp-goshen.com/wp-content/uploads/2023/04/pulse.png",
                      caption: "Thank you, this value of *#{@customer.settings.last.diastole_droit}* has been registered. \nNow we will need you to provide us with the last value located in the last position of your blood pressure monitor still placed on your right arm *(PULSE)*. \n_The one framed in red, but on your blood pressure monitor_",
                    }
                  )
                img.send_image
                @customer.update(steps: "read_poul")
              end
            else
              # creation of error logs
              @erreur = Erreur.new(
                description: @settings.errors.message,
                customer_id: @customer.id,
              )
              @erreur.save
            end
          end
        elsif @customer.steps == "read_poul"
          @settings = @customer.settings.last.update(
            poul_droit: @body,
          )

          case @customer.lang
          when "fr"
            img = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "http://coeur-vie.org/wp-content/uploads/2023/06/Screenshot-2023-06-21-at-11-28-39-Free-Vector-City-road-turn-empty-street-with-transport-highway-1.png",
                caption: "On a les informations médicales, mais j'aimerais savoir #{@customer.appelation}, dans quelle *ville/Quartier* est ce que tu vies? \n\n_Si tu habites à Douala, makepe, ecris juste *Douala, Makepe*_",
              }
            )
            img.send_image
            @customer.update(steps: "read_quartier")
          when "en"
            img = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "http://coeur-vie.org/wp-content/uploads/2023/06/Screenshot-2023-06-21-at-11-28-39-Free-Vector-City-road-turn-empty-street-with-transport-highway-1.png",
                caption: "We have at this time \n\n✅ Personnal informations\n✅medical informations\n\nNow I would like to know #{@customer.appelation}, What *city/district* do you live in? \n\n_If you live in Douala, makepe, just write *Douala, Makepe*_",
              }
            )
            img.send_image
            @customer.update(steps: "read_quartier")
          end
        elsif @customer.steps == "read_quartier"
          @settings = @customer.settings.last.update(
            quartier: @body,
          )
          case @customer.lang
          when "fr"
            q = Whatsapp::WhatsappMessages.new(
              @phone, "Vous avez terminé. \n\nNous avons un challenge qui concerne à mettre sur votre status *WhatsApp* votre photo de profile (personnalisée). \nQu'est ce que vous en pensez #{@customer.appelation}?"
            )
            q.send_message

            sleep 1
            q = Whatsapp::WhatsappMessages.new(
              @phone, "Saisir *A* si vous êtes interessé et souaitez nous envoyer votre photo de profile"
            )
            q.send_message

            sleep 1
            p1 = Whatsapp::WhatsappMessages.new(
              @phone, "Saisir *NON* si nous n'etes pas intéressé(e)."
            )
            p1.send_message
            @customer.update(steps: "read_challenge")
          when "en"
            q = Whatsapp::WhatsappMessages.new(
              @phone, "You have finished. \n\we have a challenge to put your (personalized) profile picture on your *WhatsApp* status. \nWhat do you think #{@customer.appelation}?"
            )
            q.send_message

            sleep 1
            q = Whatsapp::WhatsappMessages.new(
              @phone, "Enter *A* if you are interested and want to send us your profile picture."
            )
            q.send_message

            sleep 1
            p1 = Whatsapp::WhatsappMessages.new(
              @phone, "Enter *NO* if we are not interested."
            )
            p1.send_message
            @customer.update(steps: "read_challenge")
          end
        elsif @customer.steps == "read_challenge"
          if %w[A NON NO].include? @body
            case @body
            when "A"
              case @customer.lang
              when "fr"
                photo = Whatsapp::WhatsappMessages.new(
                  @phone, "Merci de nous fournir une photo de votre visage.\n\n*NB:* _Toutes photos autre que celle de votre visage sera rejetée._"
                )
                photo.send_message
                @customer.update(steps: "request_photo")
              when "en"
                photo = Whatsapp::WhatsappMessages.new(
                  @phone, "Please provide us with a photo of your face.\n\n*NB:* _All photos other than your face will be rejected._"
                )
                photo.send_message
                @customer.update(steps: "request_photo")
              end
            when "NON"
              case @customer.lang
              when "fr"
                query = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                    caption: "Merci de votre réponse. Retouvez toutes les informations sur le challenge  *Je connais ma tension* sur les réseaux à l'adresse \nhttps://www.facebook.com/profile.php?id=100090307216315.\n\n_Besoin de relancer un nouveau *challenge*? Saisie juste *nouveau*_",
                  }
                )
                query.send_image

                sleep 2

                photo = Whatsapp::WhatsappMessages.new(
                  @phone, "Ah j'oubliais ... \nTu peux partager ton lien et inviter egalement d'autres personnes à participer au challenge ...devient un ambassadeur en partageant ton lien et fais toi l'ambassadeur des *ambassadeurs*. Ton lien est le suivant\n\n#{@customer.linked}"
                )
                photo.send_message
              when "en"
                query = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                    caption: "Thank you for your reply. Find all the information on the challenge *I know my tension* on the networks at the address \nhttps://www.facebook.com/profile.php?id=100090307216315.\n\nNeed to start a new *challenge*? Enter just *new*_",
                  }
                )
                query.send_image

                sleep 2

                photo = Whatsapp::WhatsappMessages.new(
                  @phone, "Oh I forgot... \nYou can share your link and also invite other people to participate in the challenge ... become an ambassador by sharing your link and make yourself the ambassador of the *ambassadors* your link to share is\n*#{@customer.linked}"
                )
                photo.send_message
              end
            when "NO"
              case @customer.lang
              when "fr"
                query = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                    caption: "Merci de votre réponse. Retouvez toutes les informations sur le challenge  *Je connais ma tension* sur les réseaux à l'adresse \nhttps://www.facebook.com/profile.php?id=100090307216315.",
                  }
                )
                query.send_image

                sleep 2

                photo = Whatsapp::WhatsappMessages.new(
                  @phone, "Ah j'oubliais ... \nTu peux partager ton lien et inviter egalement d'autres personnes à participer au challenge ...devient un ambassadeur en partageant ton lien et fais toi l'ambassadeur des *ambassadeurs*. Ton lien est le suivant\n\n#{@customer.linked}"
                )
                photo.send_message
              when "en"
                query = Whatsapp::WhatsappImages.new(
                  {
                    phone: @phone,
                    file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                    caption: "Thank you for your reply. Find all the information on the challenge *I know my tension* on the networks at the address \nhttps://www.facebook.com/profile.php?id=100090307216315.",
                  }
                )
                query.send_image

                sleep 2

                photo = Whatsapp::WhatsappMessages.new(
                  @phone, "Oh I forgot... \nYou can share your link and also invite other people to participate in the challenge ... become an ambassador by sharing your link and make yourself the ambassador of the *ambassadors* your link to share is\n*#{@customer.linked}"
                )
                photo.send_message
              end
            end
            #mise à jour du des etapes
            @customer.update(steps: "end_with_rejected")
          else
            case @customer.lang
            when "fr"
              q = Whatsapp::WhatsappMessages.new(
                @phone, "Je ne parvient pas à correctement saisir votre réponse, je vais reprendre!\n\nNous avons un challenge qui concerne à mettre sur votre status *WhatsApp* votre photo de profile (personnalisée). \nQu'est ce que vous en pensez #{@customer.appelation}?"
              )
              q.send_message

              sleep 1
              q = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *A* si vous êtes interessé et souaitez nous envoyer votre photo de profile"
              )
              q.send_message

              sleep 1
              p1 = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *NON* si nous n'etes pas intéressé(e)."
              )
              p1.send_message
              @customer.update(steps: "read_challenge")
            when "en"
              q = Whatsapp::WhatsappMessages.new(
                @phone, "I can't understand your answer correctly, I'll try again!\n\nWe have a challenge to put your (personalized) profile picture on your *WhatsApp* status. \nWhat do you think #{@customer.appelation}?"
              )
              q.send_message

              sleep 1
              q = Whatsapp::WhatsappMessages.new(
                @phone, "Enter *A* if you are interested and want to send us your profile picture."
              )
              q.send_message

              sleep 1
              p1 = Whatsapp::WhatsappMessages.new(
                @phone, "Enter *NO* if we are not interested."
              )
              p1.send_message
              @customer.update(steps: "read_challenge")
            end
          end
        elsif @customer.steps == "end_with_rejected"
          # il a décidé de ne pas effectuer le challenge
          query = Whatsapp::WhatsappImages.new(
            {
              phone: @phone,
              file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
              caption: "Content de vour voir #{@customer.appelation}.\nSouhaitez vous de nouveau passer le challenge *je connais ma tension*\n\n_Ou alors vous souhaitez le faire pour un de vos proches_.",
            }
          )
          query.send_image

          sleep 1
          p1 = Whatsapp::WhatsappMessages.new(
            @phone, "Saisir *A* si vous souhaitez de nouveau passer le challenge *Je connais ma tension*."
          )
          p1.send_message
          p2 = Whatsapp::WhatsappMessages.new(
            @phone, "Saisir *B* si vous souhaitez passer le challenge *Je connais ma tension* pour un proche.\n\n_Ou juste pour une personne à vos coté à cet instant_"
          )
          p2.send_message

          p3 = Whatsapp::WhatsappMessages.new(
            @phone, "Saisir *C* si vous souhaitez obtenir et partager votre lien d'ambassadeur *Je connais ma tension*.\n\n_Etre ambassadeur me permet de savoir que je peux compter sur vous pour sauver des vies_"
          )
          p3.send_message

          p3 = Whatsapp::WhatsappMessages.new(
            @phone, "Saisir *D* si vous pensez que c'est juste une erreur, je ne souhaite rien faire maintenant."
          )
          p3.send_message

          @customer.update(steps: "request_new_challenge")
        elsif @customer.steps == "request_new_challenge"
          if %w[A B C D].include? @body
            case @customer.lang
            when "fr"
              case @body
              when "A"
                p1 = Whatsapp::WhatsappMessages.new(
                  @phone, "Super, allons y! repassons de nouveau ce challenge à nouveau."
                )
                p1.send_message

                sleep 1

                request_tensiometre_fr

                @customer.update(steps: "request_tension")
              when "B"
                p1 = Whatsapp::WhatsappMessages.new(
                  @phone, "Super, allons y! Passons un challenge pour un de vos proches."
                )
                p1.send_message

                sleep 1

                request_tensiometre_fr

                @customer.update(steps: "request_tension")
              when "C"
                p1 = Whatsapp::WhatsappMessages.new(
                  @phone, "Lien de partage\nNous allons vous passer votre lien de partage *ambassadeur*, vous pouvez le partager atour de vous, dans vos familles, vos ami(e)s.\n\n_Votre lien de partage est #{@customer.linked}._"
                )
                p1.send_message

                @customer.update(steps: "end_with_rejected")
              when "D"
                p1 = Whatsapp::WhatsappMessages.new(
                  @phone, "Merci de vous interesser au challenge *Je connais ma tension*. Nous espérons vous revoir d'ici peu #{@customer.appelation}. \n*Protegez votre coeur*!"
                )
                p1.send_message

                @customer.update(steps: "end_with_rejected")
              end
            when "en"
              case @body
              when "A"
                p1 = Whatsapp::WhatsappMessages.new(
                  @phone, "Great, let's go! let's go through this challenge again."
                )
                p1.send_message

                sleep 1

                request_tensiometre_en

                @customer.update(steps: "request_tension")
              when "B"
                p1 = Whatsapp::WhatsappMessages.new(
                  @phone, "Great, let's go! Let's take on a challenge for one of your loved ones."
                )
                p1.send_message

                sleep 1

                request_tensiometre_en

                @customer.update(steps: "request_tension")
              when "C"
                p1 = Whatsapp::WhatsappMessages.new(
                  @phone, "Sharing link\nWe will send you your *ambassador* sharing link, you can share it around you, in your families, your friends.\n\n_Your sharing link is #{@customer.linked}._"
                )
                p1.send_message

                @customer.update(steps: "end_with_rejected")
              when "D"
                p1 = Whatsapp::WhatsappMessages.new(
                  @phone, "Thank you for taking an interest in the *I know my blood pressure* challenge. We hope to see you again soon #{@customer.appelation}. \n\n*Protect your heart*!"
                )
                p1.send_message

                @customer.update(steps: "end_with_rejected")
              end
            end
          else
            case @customer.lang
            when "fr"
              query = Whatsapp::WhatsappImages.new(
                {
                  phone: @phone,
                  file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                  caption: "J'ai un peu de difficultés à lire votre choix de réponse ... essayons encore de nouveau #{@customer.appelation}.\n\n_Je pense que je pourrais mieux lire votre choix..._.",
                }
              )
              query.send_image

              sleep 1
              p1 = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *A* si vous souhaitez de nouveau passer le challenge *Je connais ma tension*."
              )
              p1.send_message
              p2 = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *B* si vous souhaitez passer le challenge *Je connais ma tension* pour un proche.\n\n_Ou juste pour une personne à vos coté à cet instant_"
              )
              p2.send_message

              p3 = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *C* si vous souhaitez obtenir et partager votre lien d'ambassadeur *Je connais ma tension*.\n\n_Etre ambassadeur me permet de savoir que je peux compter sur vous pour sauver des vies_"
              )
              p3.send_message

              p3 = Whatsapp::WhatsappMessages.new(
                @phone, "Saisir *D* si vous pensez que c'est juste une erreur, je ne souhaite rien faire maintenant."
              )
              p3.send_message
            when "en"
              query = Whatsapp::WhatsappImages.new(
                {
                  phone: @phone,
                  file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                  caption: "I'm having a bit of trouble reading your answer choice...let's try again #{@customer.appelation}.\n\n_I think I could read your choice better..._.",
                }
              )
              query.send_image

              sleep 1
              p1 = Whatsapp::WhatsappMessages.new(
                @phone, "Enter *A* if you want to take the challenge again *I know my blood pressure*."
              )
              p1.send_message
              p2 = Whatsapp::WhatsappMessages.new(
                @phone, "Enter *B* if you want to take the *I know my blood pressure* challenge for a loved one.\n\n_Or just for a person by your side at this moment_"
              )
              p2.send_message

              p3 = Whatsapp::WhatsappMessages.new(
                @phone, "Enter *C* if you want to get and share your ambassador link *I know my blood pressure*.\n\n_Being an ambassador lets me know that I can count on you to save lives_"
              )
              p3.send_message

              p3 = Whatsapp::WhatsappMessages.new(
                @phone, "Type *D* if you think it's just a mistake, I don't want to do anything now."
              )
              p3.send_message
            end

            @customer.update(steps: "request_new_challenge")
          end
        elsif @customer.steps == "request_photo"
          case @customer.lang
          when "fr"
            @down = Down.download(@image_path)
            FileUtils.mv(@down.path, "#{@customer.phone}.jpg")

            query = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                caption: "Votre image a été enregistrée! Le traitement prendra quelque secondes, mais vous serez notifié dès que le montage sera disponible.",
              }
            )
            query.send_image

            sleep 2

            # configuration
            Cloudinary.config do |config|
              config.cloud_name = "diqsvucdn"
              config.api_key = "127829381549272"
              config.api_secret = "Bv9KguwYaSSr3BtcNuhCU2YpE84"
              config.secure = true
            end

            Cloudinary::Uploader.upload @image_path, public_id: @customer.phone

            @cloudinary_image_url = Cloudinary::Utils.cloudinary_url(
              @customer.phone,
              gravity: "face",
              width: 200,
              height: 200,
              crop: "thumb",
            )

            # attache it to customer
            @face_init = Down.download(@cloudinary_image_url)
            FileUtils.mv(@face_init.path, "face_#{@customer.phone}.png")

            #call remove.bg
            RemoveBg.configure do |config|
              config.api_key = "Qp7kGiHaf2KSuhhEXAz3YMav"
            end
            removebg = RemoveBg.from_file("face_#{@customer.phone}.png")
            removebg.save("face_#{@customer.phone}.png", overwrite: true)

            @image_face = File.open("face_#{@customer.phone}.png")
            @customer.face.attach(
              io: @image_face,
              filename: "face_#{@customer.phone}.png",
              content_type: "image/jpg",
            )

            first_image = MiniMagick::Image.open(
              "http://coeur-vie.org/wp-content/uploads/2023/06/challenge-1_new.jpg"
            )
            second_image = MiniMagick::Image.open(@image_face)
            result = first_image.composite(second_image) do |c|
              c.compose "Over" # OverCompositeOp
              c.geometry "+340+200" # copy second_image onto first_image from (20, 20)
            end
            @tmp_name = SecureRandom.hex(10)

            result.write "challenge_#{@customer.phone}.jpg"

            # reimport this image
            finale_challenge = MiniMagick::Image.open("challenge_#{@customer.phone}.jpg")
            finale_challenge.combine_options do |c|
              c.font "helvetica"
              c.fill "white"
              c.pointsize 20
              c.gravity "center"
              c.draw "text 150,160 '#{@customer.real_name}'"
            end

            finale_challenge.write "challenge_#{@customer.phone}.jpg"

            # attache challenge
            @image_challenge = File.open("challenge_#{@customer.phone}.jpg")
            @customer.challenge.attach(
              io: @image_challenge,
              filename: "challenge_#{@customer.phone}.jpg",
              content_type: "image/jpg",
            )

            # send notification
            image_wa = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(@customer.challenge, only_path: true)}",
                caption: "Votre photo challenge est disponible #{@customer.appelation}, merci de la partager sur votre photo de profile. \nSaviez-vous que vous pouvez également partager ce lien et sauver des vies autour de vous? Juste en partageant votre lien d'ambassadeur \n\n #{@customer.linked}",
              }
            )
            image_wa.send_image

            sleep 1
            linked = Whatsapp::WhatsappMessages.new(
              @phone,
              "#{@customer.appelation}, nous pensons que votre engagement cache un désire plus grand...celui d'etre *embassadeur* du programme. Votre lien de partage *ambassadeur* est le suivant \n\n#{@customer.linked} \nPartagez le autour de toi, dans ta famille, sur les réseaux sociaux, parmis tes collègues...sauvez des vies."
            )
            linked.send_message
          when "en"
            @down = Down.download(@image_path)
            FileUtils.mv(@down.path, "#{@customer.phone}.jpg")

            query = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                caption: "Your image has been saved! Processing will take a few seconds, but you will be notified as soon as the mount is available.",
              }
            )
            query.send_image

            sleep 2

            # configuration
            Cloudinary.config do |config|
              config.cloud_name = "diqsvucdn"
              config.api_key = "127829381549272"
              config.api_secret = "Bv9KguwYaSSr3BtcNuhCU2YpE84"
              config.secure = true
            end

            Cloudinary::Uploader.upload @image_path, public_id: @customer.phone

            @cloudinary_image_url = Cloudinary::Utils.cloudinary_url(
              @customer.phone,
              gravity: "face",
              width: 200,
              height: 200,
              crop: "thumb",
            )

            # attache it to customer
            @face_init = Down.download(@cloudinary_image_url)
            FileUtils.mv(@face_init.path, "face_#{@customer.phone}.png")

            #call remove.bg
            RemoveBg.configure do |config|
              config.api_key = "Qp7kGiHaf2KSuhhEXAz3YMav"
            end
            removebg = RemoveBg.from_file("face_#{@customer.phone}.png")
            removebg.save("face_#{@customer.phone}.png", overwrite: true)

            @image_face = File.open("face_#{@customer.phone}.png")
            @customer.face.attach(
              io: @image_face,
              filename: "face_#{@customer.phone}.png",
              content_type: "image/jpg",
            )

            first_image = MiniMagick::Image.open(
              "http://coeur-vie.org/wp-content/uploads/2023/06/challenge-1_new.jpg"
            )
            second_image = MiniMagick::Image.open(@image_face)
            result = first_image.composite(second_image) do |c|
              c.compose "Over" # OverCompositeOp
              c.geometry "+340+200" # copy second_image onto first_image from (20, 20)
            end
            @tmp_name = SecureRandom.hex(10)

            result.write "challenge_#{@customer.phone}.jpg"

            # reimport this image
            finale_challenge = MiniMagick::Image.open("challenge_#{@customer.phone}.jpg")
            finale_challenge.combine_options do |c|
              c.font "helvetica"
              c.fill "white"
              c.pointsize 20
              c.gravity "center"
              c.draw "text 150,160 '#{@customer.real_name}'"
            end

            finale_challenge.write "challenge_#{@customer.phone}.jpg"

            # attache challenge
            @image_challenge = File.open("challenge_#{@customer.phone}.jpg")
            @customer.challenge.attach(
              io: @image_challenge,
              filename: "challenge_#{@customer.phone}.jpg",
              content_type: "image/jpg",
            )

            # send notification
            image_wa = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(@customer.challenge, only_path: true)}",
                caption: "Your photo challenge is available #{@customer.appelation}, please share it in your profile picture. \nDid you know that you can also share this link and save lives around you? Just by sharing your ambassador link \n\n #{@customer.linked}",
              }
            )
            image_wa.send_image

            sleep 1
            linked = Whatsapp::WhatsappMessages.new(
              @phone,
              "#{@customer.appelation}, we believe that your commitment hides a greater desire...that of being an *ambassador* of the program. Your *ambassador* share link is as follows \n\n#{@customer.linked} \nShare it around you, in your family, on social networks, among your colleagues...save lives."
            )
            linked.send_message
          end
        elsif @body == "nouveau" || @body == "new"
          case @customer.lang
          when "fr"
            query = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                caption: "Bonjour #{@customer.appelation}\nComment vous allez? Je vois que vous souhaitez passer le challenge à un de vos proche.\nMerci de me confirmer que c'est bien cela.",
              }
            )
            query.send_image

            sleep 1
            a = Whatsapp::WhatsappMessages.new(
              @phone, "Saisir *A* pour confirmer le nouveau challenge"
            )
            a.send_message
            b = Whatsapp::WhatsappMessages.new(
              @phone, "Saisir *B* pour annuler"
            )
            b.send_message
          when "en"
            query = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                caption: "Hello #{@customer.appelation}\nHo are you doing ? I see that you would like to pass the challenge on to someone close to you.\nPlease confirm that this is it.",
              }
            )
            query.send_image

            sleep 1
            a = Whatsapp::WhatsappMessages.new(
              @phone, "Enter *A* to confirm the new challenge"
            )
            a.send_message
            b = Whatsapp::WhatsappMessages.new(
              @phone, "Enter *B* to cancel"
            )
            b.send_message
          end
          @customer.update(steps: "request_new_challenge")
        elsif @customer.steps == "request_new_challenge"
          if %w[A B].include? @body
            case @customer.lang
            when "fr"
              case @body
              when "A"
                a = Whatsapp::WhatsappMessages.new(
                  @phone, "Vous confirmez le démarrage d'un nouveau *challenge*"
                )
                a.send_message
              when "B"
                a = Whatsapp::WhatsappMessages.new(
                  @phone, "Action de demande d'un nouveau challenge annulée"
                )
                a.send_message
              end
            when "en"
              case @body
              when "A"
                a = Whatsapp::WhatsappMessages.new(
                  @phone, "You confirm the start of a new *challenge*"
                )
                a.send_message
              when "B"
                a = Whatsapp::WhatsappMessages.new(
                  @phone, "Request action for a new challenge canceled"
                )
                a.send_message
              end
            end
          else
            query = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                caption: "Hello #{@customer.appelation}\nHo are you doing ? I see that you would like to pass the challenge on to someone close to you.\nPlease confirm that this is it.",
              }
            )
            query.send_image

            sleep 1
            a = Whatsapp::WhatsappMessages.new(
              @phone, "Enter *A* to confirm the new challenge"
            )
            a.send_message
            b = Whatsapp::WhatsappMessages.new(
              @phone, "Enter *B* to cancel"
            )
            b.send_message
          end
        elsif @customer.lang.nil?
          puts "#{@customer.pushname} has no language set"
          query = Whatsapp::WhatsappImages.new(
            {
              phone: @phone,
              file: "http://coeur-vie.org/wp-content/uploads/2023/06/translate.png",
              caption: "*Bonjour!* Veillez selectionner votre langue de conversation\n\n_*Hello!* Please select your conversation language_",
            }
          )
          query.send_image

          sleep 1

          a = Whatsapp::WhatsappMessages.new(
            @phone, "Saisir *A* pour le 🇫🇷 FRANCAIS \n====\n_Type *A* for 🇫🇷 FRENCH_"
          )
          a.send_message

          b = Whatsapp::WhatsappMessages.new(
            @phone, "Saisir *B* pour 🇬🇧 l'ANGLAIS \n====\n_Type *B* for 🇬🇧 ENGLISH_"
          )
          b.send_message

          @customer.update(steps: "select_language")
        end

        # create new entry and get settings ID
        # query = Whatsapp::WhatsappMessages.new(
        #   @phone, "Bonjour #{@customer.appelation}, souhaitez-vous de nouveau passer le challenge?"
        # )
        # query.send_message

        # sleep 1
        # o = Whatsapp::WhatsappMessages.new(
        #   @phone, "Saisir *A* pour faire un nouveau challenge"
        # )
        # o.send_message

        # sleep 1
        # n = Whatsapp::WhatsappMessages.new(
        #   @phone, "Saisir *B* pour continuer là ou je me suis arrété dernierement"
        # )
        # n.send_message

        # sleep 1
        # n = Whatsapp::WhatsappMessages.new(
        #   @phone, "Saisir *C* pour me rappeler ou m'informer de nouveau sur c'est encore quoi le challenge Je connais ma tension"
        # )
        # n.send_message

        # # update steps
        # @customer_settings = Setting.new(customer_id: @customer.id, steps: "request_question").save
        # # @customer_settings.steps == "request_question"

        # # lauching steps verifications
        # case @customer_settings.steps
        # when "request_question"
        #   n = Whatsapp::WhatsappMessages.new(
        #     @phone, "Dis quelque chose"
        #   )
        #   n.send_message
        # when ""
        # else
        # end
      else
        # create new customer
        puts "customer not found"

        begin

          # save this customer before continue
          @customer = Customer.new(
            pushname: params["data"]["pushname"],
            phone: params["data"]["from"].delete("@c.us"),
            ip: "",
          )

          if @customer.save
            query = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "http://coeur-vie.org/wp-content/uploads/2023/06/translate.png",
                caption: "*Bonjour!* Veillez selectionner votre langue de conversation\n\n_*Hello!* Please select your conversation language_",
              }
            )
            query.send_image

            sleep 1

            a = Whatsapp::WhatsappMessages.new(
              @phone, "Saisir *A* pour le 🇫🇷 FRANCAIS \n====\n_Type *A* for 🇫🇷 FRENCH_"
            )
            a.send_message

            b = Whatsapp::WhatsappMessages.new(
              @phone, "Saisir *B* pour 🇬🇧 l'ANGLAIS \n====\n_Type *B* for 🇬🇧 ENGLISH_"
            )
            b.send_message

            @customer.update(steps: "select_language")
          else
            puts "Impossible de sauvegarder cet enregistrement"
          end
        rescue => exception
          puts "Une erreur est survenue #{exception}"
        end
      end
    else
      # mal formed informations
    end
  end

  def set_new_name(response)
    @response = response
    if %w[OUI Oui oui NON Non non].include? @response
      if (@response == "OUI" || @response == "Oui" || @response == "oui")
        @customer_settings.update(name: @customer.appelation)

        # update steps
        @customer_settings.update(steps: "request_age")

        # set new question
        query = Whatsapp::WhatsappMessages.new(
          @phone, "Nous enrgistrons #{@customer_settings.name} comme votre nom! \nQuel est actuellement votre age?"
        )
        query.send_message
      else
        query = Whatsapp::WhatsappMessages.new(
          @phone, "Vous souhaitez continuer sur un nouveau nom, merci de saisir votre nouveau nom."
        )
        query.send_message
        @customer_settings.steps == "request_new_name"
      end
    else
      query = Whatsapp::WhatsappMessages.new(
        @phone, "Nous n'avons pas bien saisie votre message #{@customer.appelation}, souhaitez-vous continuer avec #{@customer.appelation} comme nom ou fournir un nouveau nom?"
      )
      query.send_message

      sleep 1
      o = Whatsapp::WhatsappMessages.new(
        @phone, "Sasir *O* pour continuer avec un nouveau nom"
      )
      o.send_message

      sleep 1
      n = Whatsapp::WhatsappMessages.new(
        @phone, "Saisir *N* pour continuer à utiliser #{@customer.appelation}"
      )
      n.send_message
    end
  end

  def salutation
    @instance = "salutation"
    query = Whatsapp::WhatsappMessages.new(@phone, "Comment je vous appelle?")
    sleep 1
    query.send_message

    # update steps
    @customer.update(steps: 1)
  end

  def get_tension_first_value(value)
    # updaye step
    @customer.update(steps: 6)

    # tout va bien
    query = Whatsapp::WhatsappMessages.new(
      @phone, "#{sexe} #{@customer.real_name}, merci de nous fournir la première valeur, celle qui a un taille d'ecriture plus grande."
    )
    query.send_message
  end

  def get_tension_second_value(value)
    # read previous message before continue
    @customer.update(systol: @body)

    # updaye step
    @customer.update(steps: 6)

    # tout va bien
    query = Whatsapp::WhatsappMessages.new(
      @phone, "Merci, nous l'avons enregistrer, maintenan pouvez-vous nous donner la seconde valeur donné par votre tensiometre, juste en dessous de la première #{@customer.appelation}"
    )
    query.send_message
  end

  def quartier
    # read previous message before continue
    @customer.update(diatol: @body)

    # updaye step
    @customer.update(steps: 6)

    # tout va bien
    query = Whatsapp::WhatsappMessages.new(
      @phone, "Nous avons presque terminer, maintenant donnez nous la valeur du poul, je pense que c'est la plus petite des valeurs de votre tensiometre #{@customer.appelation}"
    )
    query.send_message
  end

  def photo_link
    # read previous message before continue
    @customer.update(poul: @body)

    # updaye step
    @customer.update(steps: 6)

    # tout va bien
    query =
      Whatsapp::WhatsappMessages.new(
        @phone,
        "Voilaaaaaa, nous pensons avoir toutes les informations, vous venez de reussir le challenge je connais ma tention #{@customer.appelation}"
      )
    query.send_message
  end

  # module language
  # adding language analusis capabilities
  def get_lang
  end

  def send_message(phone, message)
    @phone = phone
    @message = message
    begin
      url = URI("https://api.ultramsg.com/instance41644/messages/chat")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["content-type"] = "application/x-www-form-urlencoded"
      form_data =
        URI.encode_www_form(
          {
            token: ApplicationHelper.token,
            to: "+#{ApplicationHelper.update_phone_number(@phone)}",
            body: @message,
          }
        )
      request.body = form_data

      response = http.request(request)
      puts response.read_body
    rescue => exception
      puts "Une erreur est survenue : #{exception}"
    end
  end

  def welcome_fr
    image = Whatsapp::WhatsappImages.new(
      {
        phone: @phone,
        file: "http://coeur-vie.org/wp-content/uploads/2023/06/WhatsApp-Image-2023-06-06-a-11.40.55.jpg",
        caption: "Bienvenue dans le challenge *JE CONNAIS MA TENSION*. Dont le thème est : Se *dépister et faire dépister les autres*",
      }
    )
    image.send_image
    # message.send_message
    sleep 1
    query = Whatsapp::WhatsappImages.new(
      {
        phone: @phone,
        file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
        caption: "Notre challenge vise à ce que tout le monde autour de nous connaisse sa tension artérielle et ainsi réduire les cas d'AVC. Acceptes tu le challenge? \nJe suis le Dr *CARDIO* de la Fondation Coeur et Vie et c'est moi qui vais t'accompagner durant cette courte aventure.",
      }
    )
    query.send_image

    sleep 2

    query1 = Whatsapp::WhatsappMessages.new(
      @phone, "Pour confirmer que vous acceptez le *challenge*, comment je vous appelle?\n\n_En acceptant le challenge *Je Connais ma Tension* vous acceptez les regles de confidentialités disponibles sur notre site web http://coeur-vie.org/privacy_"
    )
    query1.send_message
  end

  def welcome_en
    image = Whatsapp::WhatsappImages.new(
      {
        phone: @phone,
        file: "http://coeur-vie.org/wp-content/uploads/2023/06/WhatsApp-Image-2023-06-06-a-11.40.55.jpg",
        caption: "Welcome to the *I KNOW MY TENSION* challenge. Whose theme is: *Test yourself and get others tested*",
      }
    )
    image.send_image
    # message.send_message
    sleep 1
    query = Whatsapp::WhatsappImages.new(
      {
        phone: @phone,
        file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
        caption: "Our challenge aims for everyone around us to know their blood pressure and thus reduce cases of stroke. Do you accept the challenge? \nI'm Dr *CARDIO* from the Heart and Life Foundation and I'm the one who will accompany you during this short adventure.",
      }
    )
    query.send_image

    sleep 2

    query1 = Whatsapp::WhatsappMessages.new(
      @phone, "To confirm that you accept the *challenge*, what do I call you?\n\n_By accepting the *I Know My Blood Pressure* challenge you agree to the privacy policy available on our website http://coeur-vie.org/privacy_"
    )
    query1.send_message
  end

  # request customer language
  def request_language
    query = Whatsapp::WhatsappImages.new(
      {
        phone: @phone,
        file: "http://coeur-vie.org/wp-content/uploads/2023/06/translate.png",
        caption: "*Bonjour!* Veillez selectionner votre langue de conversation\n\n_*Hello!* Please select your conversation language_",
      }
    )
    query.send_image

    sleep 1

    a = Whatsapp::WhatsappMessages.new(
      @phone, "Saisir *A* pour le 🇫🇷 FRANCAIS \n====\n_Type *A* for 🇫🇷 FRENCH_"
    )
    a.send_message

    b = Whatsapp::WhatsappMessages.new(
      @phone, "Saisir *B* pour 🇬🇧 l'ANGLAIS \n====\n_Type *B* for 🇬🇧 ENGLISH_"
    )
    b.send_message
  end

  # request sexe informations
  def request_sexe_fr
    a = Whatsapp::WhatsappMessages.new(
      @phone, "Merci, j'enregistre *#{@customer.real_name.upcase}* comme votre nom. En passant, pourrais-je avoir votre *sexe*?"
    )
    a.send_message

    sleep 1
    sm = Whatsapp::WhatsappMessages.new(
      @phone, "Saisir *A* pour le sexe *MASCULIN*"
    )
    sm.send_message

    sf = Whatsapp::WhatsappMessages.new(
      @phone, "Saisir *B* pour le sexe *FEMININ*"
    )
    sf.send_message
  end

  # request sexe informations
  def request_sexe_en
    a = Whatsapp::WhatsappMessages.new(
      @phone, "Thanks, I'm recording *#{@customer.real_name.upcase}* like your name. By the way, could I have your *gender*?"
    )
    a.send_message

    sleep 1
    sm = Whatsapp::WhatsappMessages.new(
      @phone, "Enter *A* for *MALE* gender"
    )
    sm.send_message

    sf = Whatsapp::WhatsappMessages.new(
      @phone, "Enter *B* for *FEMALE* gender"
    )
    sf.send_message
  end

  # request tensiome information french
  def request_tensiometre_fr
    query = Whatsapp::WhatsappMessages.new(
      @phone, "Maintenant nous allons passer aux informations *médicales*, à savoir prendre votre tension arterielle #{@customer.appelation}. Mais avant nous souhaiterions nous rassurer d'une chose"
    )
    query.send_message

    sleep 1
    # check if customer have tools
    query0 = Whatsapp::WhatsappMessages.new(
      @phone, "Avez-vous un *tensiomètre* à votre disposition actuellement #{@customer.appelation}."
    )
    query0.send_message

    sleep 1
    a = Whatsapp::WhatsappMessages.new(
      @phone, "Saisir *A* si vous avez pris votre tension artérielle"
    )
    a.send_message

    sleep 1
    b = Whatsapp::WhatsappMessages.new(
      @phone, "Saisir *B* si vous allez le faire plus tard car ne disposant pas de tensiomètre"
    )
    b.send_message

    sleep 1
    c = Whatsapp::WhatsappMessages.new(
      @phone, "Saisir *C* pour savoir ce que c'est un *tensiomètre*"
    ) #https://fr.wikipedia.org/wiki/Tensiomètre #https://fr.wikihow.com/lire-sa-tension-artérielle-avec-un-tensiomètre
    c.send_message
  end

  # request tensiometre information english
  def request_tensiometre_en
    query = Whatsapp::WhatsappMessages.new(
      @phone, "Now we are going to move on to the *medical* information, namely taking your blood pressure #{@customer.appelation}. But before we would like to reassure ourselves of one thing"
    )
    query.send_message

    # ====== other
    sleep 1
    query = Whatsapp::WhatsappImages.new(
      {
        phone: @phone,
        file: "http://coeur-vie.org/wp-content/uploads/2023/06/Screenshot-2023-06-21-at-13-08-44-Premium-Vector-Electronic-blood-pressure-monitor-isolated-on-white-modern-medical-device.-vector-illustration.png",
        caption: "Do you currently have a *blood pressure monitor* at your disposal? #{@customer.appelation}.",
      }
    )
    query.send_image

    sleep 1
    a = Whatsapp::WhatsappMessages.new(
      @phone, "Enter *A* if you took your blood pressure"
    )
    a.send_message

    sleep 1
    b = Whatsapp::WhatsappMessages.new(
      @phone, "Enter *B* if you are going to do it later because you don't have a blood pressure monitor"
    )
    b.send_message

    sleep 1
    c = Whatsapp::WhatsappMessages.new(
      @phone, "Enter *C* to find out what a *blood pressure monitor* is"
    )
    c.send_message
  end

  # private method
  private

  def check_language
    puts "hello"
    if (params["data"].present?)
      @instance = "none"
      puts params
      @body = params["data"]["body"]
      @image_type = params["data"]["type"]
      @image_path = params["data"]["media"]
      @name = params["data"]["pushname"]
      @phone = params["data"]["from"].delete("@c.us")

      # search customer
      @customer = Customer.find_by_phone(@phone)
      if @customer
        if @customer.lang.nil?
          # return nos informations found for this customer, it's theoricaly a new customer
          puts "no settings language found : #{@customer.lang}"

          sleep 2
          query = Whatsapp::WhatsappMessages.new(
            @phone, "Bonjour! Avant de commencer notre voyage dans ce *challenge*, j'aimerais savoir quelle langue vous parlez?\n\n_Hi! Before we start our journey in this *challenge*, I would like to know what language you speak?_"
          )
          query.send_message

          a = Whatsapp::WhatsappMessages.new(
            @phone, "Saisir *A* pour le 🇫🇷 FRANCAIS \n\n_Type *A* for FRENCH_"
          )
          a.send_message

          b = Whatsapp::WhatsappMessages.new(
            @phone, "Saisir *B* pour l'ANGLAIS \n\n_Type *B* for 🇬🇧 ENGLISH_"
          )
          b.send_message

          @customer.update(steps: "select_language")
        else
          # we found new customer
          puts "foud setting language : #{@customer.lang}"
        end
      else
        # not new customer find
        puts "No customer found, we have to create new"
      end
    else
    end
  end
end
