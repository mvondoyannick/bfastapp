desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  puts "Updating feed..."
  Customer.all.each do |customer|
    if customer.date_rappel.nil?
      puts 'not found date rappel'
    else 
      if customer.date_rappel.to_datetime.after?(DateTime.now)
        #get cusomer information
        @phone = customer.phone

        # get steps
        @steps = customer.steps 

        case @steps
        when 'need_rappel'
          w = Whatsapp::WhatsappMessages.new(@phone, "Hello *#{customer.real_name.upcase}*, comment vous allez? c'est *CADIO*, votre compagnon pour le challenge Je connais ma tension*.")
          w.send_message  

          sleep 1
          text = Whatsapp::WhatsappMessages.new(@phone, "Je reviens vers vous parce que nous avons un rendez-vous aujourd'hui, so vous êtes d'accord, merci de repondre par 'ok'.")
          text.send_message        
        end

      else
        puts 'none'
      end
    end
  end
  puts "done."
end

desc "photos collage"
task :manage_photo => :environment do
  puts "generating collage..."
end