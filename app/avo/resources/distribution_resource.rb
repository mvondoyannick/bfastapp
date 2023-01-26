class DistributionResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], phone_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  # Fields generated from the model
  field :logo, as: :file, is_image: true, accept: "image/*", required: true
  field :name, as: :text, link_to_resource: true
  field :phone, as: :text
  field :email, as: :text
  field :ville, as: :text
  field :images, as: :files, is_image: true, accept: "Image/*", required: true
  field :entreprise, as: :belongs_to
  field :latitude, as: :text, required: true, hide_on: [:index]
  field :longitude, as: :text, required: true, hide_on: [:index]
  field "location", as: :text, hide_on: [:index, :edit] do |model|
    begin
      results = Geocoder.search([model.latitude, model.longitude])
      results.first.address  
    rescue => exception
      "Impossible de geolocaliser"
    end
  end
  # add fields here
end
