class SendMessage < Avo::BaseAction
  self.name = "Envoyer un message"
  self.message = "Etes vous certain d'envoyer ce message?"
  # self.visible = -> do
  #   true
  # end

  field :notify_user, as: :boolean, default: true
  field :message, as: :textarea, placeholder: "Saisir une information à envoyer"

  def handle(**args)
    models, fields, current_user, resource = args.values_at(:models, :fields, :current_user, :resource)

    models.each do |model|
      # set new question
      query = Whatsapp::WhatsappMessages.new(
        model.phone, "#{fields["message"]}"
      )
      query.send_message
    end

    succeed "Message envoyé!"
  end
end
