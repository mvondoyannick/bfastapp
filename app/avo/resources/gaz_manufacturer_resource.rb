class GazManufacturerResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  grid do
    cover :image, as: :file, link_to_resource: true
    title :name, as: :text, required: true, link_to_resource: true
    body :link, as: :text
  end

  field :id, as: :id
  # Fields generated from the model
  field :image, as: :file, is_image: true, required: true, accept: "image/*"
  field :name, as: :text, required: true, name:"Fabriquant"
  field :link, as: :text
  # add fields here
end
