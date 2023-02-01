class GazFournisseurResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], email_cont: params[:true], phone_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  # Fields generated from the model
  field :images, as: :files, is_image: true, accept: "image/*", required: true
  field :name, as: :text
  field :email, as: :text
  field :phone, as: :text
  field :ville, as: :belongs_to
  field :latitude, as: :number
  field :longitude, as: :number
  field "location", as: :text, hide_on: [:index, :edit] do |model|
    begin
      results = Geocoder.search([model.latitude, model.longitude])
      results.first.address  
    rescue => exception
      "Impossible de geolocaliser"
    end
  end
  field :gaz_bottles, as: :has_and_belongs_to_many
  # add fields here
end
