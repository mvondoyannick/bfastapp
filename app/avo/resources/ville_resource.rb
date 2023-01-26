class VilleResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text, link_to_resource: true, required: true
  field :code, as: :text
  field :token, as: :text
  field :latitude, as: :text, required: true 
  field :longitude, as: :text, required: true
  field "location", as: :text, hide_on: [:index, :edit] do |model|
    begin
      results = Geocoder.search([model.latitude, model.longitude])
      results.first.address  
    rescue => exception
      "Impossible de geolocaliser"
    end
  end
  field :resume, as: :text, hide_on: [:index]
  field :buses, as: :has_many
  field :travel_agences, as: :has_many
  # add fields here
end
