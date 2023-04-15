class CustomerResource < Avo::BaseResource
  self.title = :real_name
  self.includes = []
  self.search_query = -> do
    scope.ransack(
      id_eq: params[:q],
      pushname_cont: params[:q],
      real_name_cont: params[:q],
      m: "or"
    ).result(distinct: false)
  end

  field :id, as: :id
  # Fields generated from the model
  heading "Information d'identication"
  field :pushname, as: :text
  field :real_name, as: :text
  field :phone, as: :text
  field :ip, as: :text, hide_on: [:index]
  field :sexe, as: :text, hide_on: [:index]
  field :age, as: :text, hide_on: [:index]
  heading "Parametres bras droit"
  field :tension_droit, as: :text, hide_on: [:index]
  field :diastole_droit, as: :text
  field :poul_droit, as: :text, hide_on: [:index]
  heading "Parametres bras gauche"
  field :tension_gauche, as: :text, hide_on: [:index]
  field :diastole_gauche, as: :text, hide_on: [:index]
  field :poul_gauche, as: :text, hide_on: [:index]
  field :quartier, as: :text
  heading "Etape de progression"
  field :steps, as: :text, hide_on: [:index]
  field :link, as: :text, hide_on: [:index]
  field :code, as: :text, hide_on: [:index]
  field :linked, as: :text, hide_on: [:index]
  heading "Information de rappel"
  field :rappel, as: :text, hide_on: [:index]
  field :rappel_day, as: :text, hide_on: [:index]
  field :date_rappel, as: :text, hide_on: [:index]
  heading "Information interne supplementaires"
  field :body, as: :trix
  field :qr_code, as: :file, is_image: true, hide_on: [:index]
  field :photo, as: :text, hide_on: [:index]
  field :photo, as: :external_image, hide_on: [:index]
  field "photo cropped", as: :external_image, hide_on: [:index] do |model|
    if model.photo.empty? || model.photo.nil?
      "Aucune image trouvée"
    else
      ApplicationHelper.cloudinary(model.phone, model.photo)
    end
  end

  # add fields here
end
