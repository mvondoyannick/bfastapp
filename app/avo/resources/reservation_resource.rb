class ReservationResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], customer_name_cont: params[:q], customer_second_name_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  field :token, as: :text, readonly: true
  # Fields generated from the model
  field :horaire, as: :belongs_to
  field :bus, as: :belongs_to, name: "Immatriculation bus"
  field "depart", as: :text, name: "Ville départ", hide_on: [:index, :edit, :new] do |model|
    if model.ville.name == "Douala"
      "Yaoundé"
    else
      "Douala"
    end
  end
  field 'durée', as: :text, name: "Durée du trajet", hide_on: [:index, :edit, :new] do |model|
    "04 heures"
  end
  field :ville, as: :belongs_to, name: "Ville arrivée"
  field 'montant', as: :text, hide_on: [:index, :edit, :new] do |model|
    "#{model.horaire.amount}F CFA"
  end
  #heading "Information du client"
  panel name: "Informations client", description: "Informations personnelles du client" do
    field :customer_name, as: :text, name: "Nom"
    field :customer_second_name, as: :text, name: "Prenom"
    field :customer_phone, as: :text, name: "Telephone"
    field 'Telephone', as: :text do |model|
      "Samsung"
    end
  end
  field :created_at, as: :date_time, name: "Date creation"
  tabs do
    tab "Document du client", description: "Ceci est une information" do
      panel do 
        field 'Photo CNI recto', as: :text
        field 'Photo CNI verso', as: :text
        field 'cni et proprietaire', as: :text
      end
    end
    tab "Info bus", description: "Ceci est une information" do
      panel do 
        field 'Marque', as: :text do |model|
          model.bus.brand
        end
        field 'image', as: :text do |model|
          # image_tag model.bus.image
        end
        field 'cni et proprietaire', as: :text
      end
    end
    tab "Info nutrition", description: "Ceci est une information" do
      panel do 
        field 'Alimentation', as: :text do |model|
          model.horaire.food.name
        end
        field 'Boisson', as: :text do |model|
          model.horaire.drink.name
        end
        field 'montant', as: :text do |model|
          model.horaire
        end
      end
    end
  end
  field :qr_code, as: :file, is_image: true
  # add fields here
end
