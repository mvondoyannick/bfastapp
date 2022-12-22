class CustomerResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :email, as: :text
  field :name, as: :text
  field :second_name, as: :text
  field :phone, as: :text
  field :sexe, as: :text
  field :token, as: :text
  # add fields here
end
