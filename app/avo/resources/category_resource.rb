class CategoryResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  grid do
    cover :logo, as: :file, link_to_resource: true
    title :name, as: :text, required: true, link_to_resource: true
    body :token, as: :text
  end

  field :id, as: :id
  # Fields generated from the model
  field :logo, as: :file, is_image: true, required: true, accept: "image/*"
  field :name, as: :text, link_to_resource: true
  field :token, as: :text, readonly: true, help: "Generé automatiquement"
  # add fields here
  # link categories with products
  field :products, as: :has_many
end
