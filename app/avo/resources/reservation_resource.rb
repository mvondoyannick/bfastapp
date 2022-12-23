class ReservationResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], customer_name_cont: params[:q], customer_second_name_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  field :customer, as: :belongs_to
  field :token, as: :text, readonly: true
  # Fields generated from the model
  #field :horaire, as: :belongs_to
  field :depart, as: :text 
  field :arrivee, as: :text 
  field :date_depart, as: :text 
  field :heure, as: :text 
  field :customer_phone_payment, as: :number
  field :amount, as: :number 
  field :paid, as: :boolean 
  field :fee, as: :number
  field 'durée', as: :text, name: "Durée du trajet", hide_on: [:index, :edit, :new] do |model|
    "04 heures"
  end
  #heading "Information du client"
  # panel name: "Informations client", description: "Informations personnelles du client" do
  #   field :customer_name, as: :text, name: "Nom"
  #   field :customer_second_name, as: :text, name: "Prenom"
  #   field :customer_phone, as: :text, name: "Telephone"
  #   field 'Telephone', as: :text do |model|
  #     "Samsung"
  #   end
  # end

  # panel name: "Informations du voyage", description: "Informations personnelles du client" do
  #   field :depart, as: :text, name: "Lieu de depart"
  #   field :arrivee, as: :text, name: "Destination"
  #   field :date_depart, as: :text 
  #   field :heure, as: :text 
  # end

  # panel name: "Informations de paiement", description: "Informations personnelles du client" do
  #   field :customer_phone_payment, as: :number
  #   field :amount, as: :number 
  #   field :paid, as: :boolean 
  #   field :fee, as: :number
  # end

  field :created_at, as: :date_time, name: "Date creation", readonly: true
  # tabs do
  #   tab "Client", description: "Information sur le client" do
  #     panel do 
  #       field 'Photo CNI recto', as: :text
  #       field 'Photo CNI verso', as: :text
  #       field 'cni et proprietaire', as: :text
  #     end
  #   end
  #   tab "Voyage et destination", description: "Ceci est une information" do
  #     panel do 
  #       field 'Marque', as: :text do |model|
  #         model.bus.brand
  #       end
  #       field 'image', as: :text do |model|
  #       end
  #       field 'cni et proprietaire', as: :text
  #     end
  #   end
  #   tab "Transaction et paiement", description: "Ceci est une information" do
  #     panel do 
  #       field 'Alimentation', as: :text do |model|
  #         model.horaire.food.name
  #       end
  #       field 'Boisson', as: :text do |model|
  #         model.horaire.drink.name
  #       end
  #       field 'montant', as: :text do |model|
  #         model.horaire
  #       end
  #     end
  #   end
  #   tab "Localisation et suivie", description: "Ceci est une information" do
  #     panel do 
  #       field 'Alimentation', as: :text do |model|
  #         model.horaire.food.name
  #       end
  #       field 'Boisson', as: :text do |model|
  #         model.horaire.drink.name
  #       end
  #       field 'montant', as: :text do |model|
  #         model.horaire
  #       end
  #     end
  #   end
  #   tab "Autres informations", description: "Toutes informations utiles" do
  #     panel do 
  #       field 'Alimentation', as: :text do |model|
  #         model.horaire.food.name
  #       end
  #       field 'Boisson', as: :text do |model|
  #         model.horaire.drink.name
  #       end
  #       field 'montant', as: :text do |model|
  #         model.horaire
  #       end
  #     end
  #   end
  # end
  field :qr_code, as: :file, is_image: true
  # add fields here
end
