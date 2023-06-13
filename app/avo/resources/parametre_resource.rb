class ParametreResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :tension_droite, as: :text
  field :tension_gauche, as: :text
  field :quartier, as: :text
  field :steps, as: :text
  field :code, as: :text
  field :diastole_droit, as: :text
  field :diastole_gauche, as: :text
  field :poul_droit, as: :text
  field :poul_gauche, as: :text
  field :linked, as: :text
  field :question_tension, as: :text
  field :rappel, as: :text
  field :rappel_day, as: :text
  field :date_rappel, as: :text
  field :photo, as: :text
  field :photo_type, as: :text
  field :is_cropped, as: :boolean
  field :cropped, as: :text
  field :poids, as: :text
  field :taille, as: :text
  # add fields here
end
