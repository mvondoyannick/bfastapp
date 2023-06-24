class SettingResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :created_at, as: :date_time, link_to_resource: true
  field "name", as: :text, link_to_resource: true do |model|
    model.customer.real_name.nil? ? model.customer.pushname : model.customer.real_name
  end
  field :quartier, as: :text do |model|
    model.quartier.nil? ? "Not defined" : model.quartier
  end
  heading "Information de parcours"
  field "steps", as: :status do |model|
    model.customer.steps.nil? ? "Aucune etape" : model.customer.steps
  end
  field :code, as: :text, hide_on: [:index] do |model|
    model.customer.code
  end
  heading "Informations médicale"

  tabs do
    tab "Bras droit", description: "Informations bras droit" do
      panel do
        field :tension_droite, as: :text, hide_on: [:index]
        field :diastole_droit, as: :text, hide_on: [:index]
        field :poul_droit, as: :text, hide_on: [:index]
      end
    end

    tab "Bras gauche", description: "Informations bras droit" do
      panel do
        field :tension_gauche, as: :text, hide_on: [:index]
        field :diastole_gauche, as: :text, hide_on: [:index]
        field :poul_gauche, as: :text, hide_on: [:index]
      end
    end

    tab "Date & rappels", description: "Informations bras droit" do
      panel do
        field :rappel, as: :text, hide_on: [:index]
        field :rappel_day, as: :text, hide_on: [:index]
        field :date_rappel, as: :text, hide_on: [:index]
      end
    end

    tab "Photos", description: "Informations bras droit" do
      panel do
        field :photo, as: :text, hide_on: [:index]
        field :photo_type, as: :text, hide_on: [:index]
        field :cropped, as: :text, hide_on: [:index]
        field :is_cropped, as: :boolean, hide_on: [:index]
      end
    end
  end

  field :question_tension, as: :text, hide_on: [:index]
  heading "Information personnelle"

  field :poids, as: :text, hide_on: [:index] do |model|
    "#{model.poids.present? ? model.poids : model.customer.poids}Kg"
  end
  field :taille, as: :text, hide_on: [:index] do |model|
    "#{model.taille.present? ? model.taille : model.customer.taille}cm"
  end
  heading "Liaison patient"
  field :linked, as: :text, hide_on: [:index]
  field :customer, as: :belongs_to, name: "Patient"
  # add fields here
end
