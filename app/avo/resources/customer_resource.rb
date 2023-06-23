class CustomerResource < Avo::BaseResource
  self.title = :pushname
  self.includes = []
  self.search_query = -> do
    scope.ransack(
      id_eq: params[:q],
      pushname_cont: params[:q],
      real_name_cont: params[:q],
      m: "or",
    ).result(distinct: false)
  end

  grid do
    cover :face, as: :file, is_image: true, radius: 25, link_to_resource: true
    title :real_name, as: :text, required: true, link_to_resource: true
    body :excerpt, as: :text do |model|
      "Challenge accepted\n#{model.phone}" if model.photo.present?
    end
  end

  field :id, as: :id
  field :created_at, as: :date_time
  # field :face, as: :file, is_image: true, radius: "25"
  field :lang, as: :text, name: "Langue" do |model|
    model.lang == "fr" ? "🇫🇷 Français" : "🇬🇧 English"
  end
  # Fields generated from the model
  heading "Information d'identication"
  field :pushname, as: :text, link_to_resource: true
  field :real_name, as: :text, link_to_resource: true
  field :phone, as: :text
  field :ip, as: :text, hide_on: [:index]
  field :sexe, as: :text, hide_on: [:index]
  field :age, as: :text, hide_on: [:index]
  field :taille, as: :text, hide_on: [:index]
  field :poids, as: :text, hide_on: [:index]
  # heading "Parametres bras droit"
  # field :tension_droit, as: :text, hide_on: [:index]
  # field :diastole_droit, as: :text, hide_on: [:index]
  # field :poul_droit, as: :text, hide_on: [:index]
  heading "Localisation"
  # field :tension_gauche, as: :text, hide_on: [:index]
  # field :diastole_gauche, as: :text, hide_on: [:index]
  # field :poul_gauche, as: :text, hide_on: [:index]
  field :quartier, as: :text, hide_on: [:index]
  heading "Etape de progression"
  field :steps, as: :text, hide_on: [:index], name: "Etape courante"
  field :link, as: :text, hide_on: [:index]
  field :code, as: :text, hide_on: [:index]
  field :linked, as: :text, hide_on: [:index], name: "Lien ambassadeur" do |model|
    model.linked.nil? ? "Aucun lien généré" : model.linked
  end
  heading "Information de rappel"
  field :rappel, as: :text, hide_on: [:index] do |model|
    model.rappel.present? ? "Aucun rappel" : model.rappel
  end
  field :rappel_day, as: :text, hide_on: [:index] do |model|
    model.rappel_day.present? ? "Aucun jour de rappel" : model.rappel_day
  end
  field :date_rappel, as: :text, hide_on: [:index] do |model|
    model.date_rappel.nil? ? "Aucune date de rappel" : model.date_rappel
  end
  heading "Information interne supplementaires"
  field :body, as: :trix
  field :qr_code, as: :file, is_image: true, hide_on: [:index]
  field :photo, as: :text, hide_on: [:index]
  field :photo, as: :external_image, hide_on: [:index]
  field :challenge, as: :file, is_image: true, hide_on: [:index]
  field :settings, as: :has_many, name: "Paramètres patients"
  field :erreurs, as: :has_many, name: "Journal des erreurs"

  # add fields here
  filter SexeFilter

  # actions
  action SendMessage
  action ExportCsv

  field :excerpt, as: :text, as_description: true do |model|
    ActionView::Base.full_sanitizer.sanitize(model.phone).truncate 130
  rescue
    ""
  end

  field :face, as: :file, is_image: true, as_avatar: :rounded
end
