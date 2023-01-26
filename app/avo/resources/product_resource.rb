class ProductResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], amount_cont: params[:q], m: "or").result(distinct: false)
  end

  grid do
    cover :image, as: :file, link_to_resource: true
    title :name, as: :text, required: true, link_to_resource: true
    body "amount", as: :text do |model|
      "#{model.amount}F - #{model.category.name}"
    end
  end

  field :id, as: :id
  # Fields generated from the model
  field :image, as: :file, is_image: true, required: true, accept: "image/*", help: "Image du produit"
  field :name, as: :text, link_to_resource: true
  field :amount, as: :text
  field :category, as: :belongs_to
  field :distribution, as: :belongs_to, name: "Supermarché"
  field :promotion, as: :boolean
  field :promotion_amount, as: :text
  field :promotion_begin, as: :date_time
  field :promotion_end, as: :date_time
  field :galeries, as: :files, is_image: true, accept: "image/*", help: "Galerie d'images pour le produit"
  # add fields here

   # for searching
  field :name, as: :text, as_description: true, hide_on: [:index, :show, :edit, :new]
  field :image, as: :file, as_avatar: :rounded, hide_on: [:index, :show, :edit, :new]
end
