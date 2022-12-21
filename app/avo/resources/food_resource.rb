class FoodResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :image, as: :file, is_image: true
  field :name, as: :text, required: true
  field :amount, as: :select, options: {"Gratuit": "gratuit"}, required: true
  field :description, as: :trix, required: true
  field :horaires, as: :has_many
  # add fields here
end
