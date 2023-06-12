namespace :me do
  desc "This task is called by the Heroku scheduler add-on"
  task :update_feed => :environment do
    puts "Updating feed..."
    Customer.all.each do |customer|
      if customer.date_rappel.nil?
        puts "Aucun rappel pour #{customer.phone}"
      else
        # Si la date est après la date courante (dans le futur), on ne fait rien
        if customer.date_rappel.to_datetime.after?(DateTime.now)
          puts "Nothing to do, ce rappel est programmé dans le futur"
        else
          #get cusomer information
          @phone = customer.phone

          # get steps
          @steps = customer.steps

          case @steps
          when "need_rappel"
            w = Whatsapp::WhatsappMessages.new(@phone, "Hello *#{customer.real_name.upcase}*, comment vous allez? c'est *CADIO*, votre compagnon pour le challenge Je connais ma tension*.")
            w.send_message

            sleep 1
            query = Whatsapp::WhatsappImages.new(
              {
                phone: @phone,
                file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
                caption: "Je reviens vers vous parce que nous avons un rendez-vous aujourd'hui.",
              }
            )
            query.send_image

            sleep 1
            query0 = Whatsapp::WhatsappMessages.new(
              @phone, "Avez-vous un *tensiomètre* à votre disposition actuellement #{customer.appelation}."
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
            )
            c.send_message

            # nous devons reset les informations de date_rappel à nil
            customer.update(date_rappel: nil, steps: "QT")
          end
        end
      end
    end
    puts "done."
  end

  # every day, say good morning
  desc "Good morning"
  task :say_good_morning => :environment do
    puts "Say good morning to customer"
    Customer.all.each do |customer|
      query = Whatsapp::WhatsappImages.new(
        {
          phone: @phone,
          file: "https://mppp-goshen.com/wp-content/uploads/2023/05/WhatsApp-Image-2023-04-21-a-07.14.34.jpg",
          caption: "Bonjour #{customer.appelation}, comment vous allez le ce matin?",
        }
      )
      query.send_image
    end
  end

  desc "photos collage"
  task :manage_photo => :environment do
    puts "generating collage..."
    puts "done !"
    Customer.all.each do |customer|
      query = Whatsapp::WhatsappImages.new(
        {
          phone: customer.phone,
          file: "http://coeur-vie.org/wp-content/uploads/2023/06/tabac.png",
          caption: "Bonjour, c'est le Dr *CARDIO* de la *Fondation Coeur et Vie*, \nj'aimerais partager une actualité avec toi ce matin. \n\n http://coeur-vie.org/2023/06/12/les-effets-de-la-cigarette-sur-le-coeur-sont-pires-que-ce-que-lon-pensait/, \n\n_#{customer.appelation} partage à quelqu'unu pour sauver des vies_",
        }
      )
      query.send_image
    end

    # b = Whatsapp::WhatsappMessages.new(
    #   237691451189, "Bonjour, j'aimerais partager une information avec vous ce matin. \n\n http://coeur-vie.org/2023/06/12/les-effets-de-la-cigarette-sur-le-coeur-sont-pires-que-ce-que-lon-pensait/, \n\n_Partage à quelqu'unu pour sauver des vies_"
    # )
    # b.send_message
  end
end
