class EntrepriseResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :logo, as: :file, is_image: true, accept: "image/*"
  field :name, as: :text, link_to_resource: true
  field :email, as: :text
  field :phone, as: :text
  field :as_agence, as: :boolean, name: "Dispose d'agence", required: true
  # add fields here
end
