class TravelAgenceResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  grid do
    cover :image, as: :file, link_to_resource: true
    title :name, as: :text, required: true, link_to_resource: true
    body "location", as: :text do |model|
      begin
        results = Geocoder.search([model.latitude, model.longitude])
        results.first.address  
      rescue => exception
        "Impossible de geolocaliser"
      end
    end
  end

  field :id, as: :id
  # Fields generated from the model
  field :image, as: :file, is_image: true, required: true, accept: "image/*"
  field :name, as: :text
  field :latitude, as: :number
  field :longitude, as: :number
  field :active, as: :boolean
  field :ville, as: :belongs_to
  field :travel_entreprise, as: :belongs_to
  field "location", as: :text, hide_on: [:index, :edit] do |model|
    begin
      results = Geocoder.search([model.latitude, model.longitude])
      results.first.address  
    rescue => exception
      "Impossible de geolocaliser : #{exception}"
    end
  end
  # add fields here
end
