class TravelEntrepriseResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  grid do
    cover :image, as: :file, link_to_resource: true
    title :name, as: :text, required: true, link_to_resource: true
    body :phone, as: :text
  end

  field :id, as: :id
  # Fields generated from the model
  field :image, as: :file, is_image: true, accept: "image/*", requred: true
  field :name, as: :text
  field :phone, as: :text
  field :email, as: :text
  field :token, as: :text, readonly: true
  # add fields here
end
