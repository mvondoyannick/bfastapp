class SettingResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :created_at, as: :date_time
  field :name, as: :text, link_to_resource: true
  field :quartier, as: :text
  heading "Information de parcours"
  field :steps, as: :text
  field :code, as: :text
  heading "Informations médicale"
  field :tension_droite, as: :text
  field :tension_gauche, as: :text
  field :diastole_droit, as: :text
  field :diastole_gauche, as: :text
  field :poul_droit, as: :text
  field :poul_gauche, as: :text
  field :question_tension, as: :text
  heading "Informations de temps"
  field :rappel, as: :text
  field :rappel_day, as: :text
  field :date_rappel, as: :text
  heading "Information personnelle"
  field :photo, as: :text
  field :photo_type, as: :text
  field :poids, as: :text
  field :taille, as: :text
  field :cropped, as: :text
  field :is_cropped, as: :boolean
  heading "Liaison patient"
  field :linked, as: :text
  field :customer, as: :belongs_to
  # add fields here
end
