class CustomerResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :pushname, as: :text
  field :real_name, as: :text
  field :phone, as: :text
  field :ip, as: :text, hide_on: [:index]
  field :sexe, as: :text, hide_on: [:index]
  field :age, as: :text, hide_on: [:index]
  field :tension_gauche, as: :text, hide_on: [:index]
  field :tension_droit, as: :text, hide_on: [:index]
  field :quartier, as: :text
  field :link, as: :text, hide_on: [:index]
  field :steps, as: :text, hide_on: [:index]
  field :code, as: :text, hide_on: [:index]
  field :diastole_droit, as: :text
  field :diastole_gauche, as: :text
  field :poul_droit, as: :text, hide_on: [:index]
  field :poul_gauche, as: :text, hide_on: [:index]
  field :linked, as: :text, hide_on: [:index]
  field :rappel, as: :text, hide_on: [:index]
  field :rappel_day, as: :text, hide_on: [:index]
  # add fields here
end
