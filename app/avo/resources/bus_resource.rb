class BusResource < Avo::BaseResource
  self.title = :name
  self.description = "Liste de nos bus"
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], immatriculation_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  # Fields generated from the model
  field :image, as: :file, is_image: true, required: true
  field :name, as: :text
  field :immatriculation, as: :text
  field :chassis, as: :text
  field :brand, as: :text
  field :modele, as: :text
  field :horaires, as: :has_many
  field :ville, as: :belongs_to

  # for searching
  field :immatriculation, as: :text, as_description: true, hide_on: [:index, :show, :edit, :new]
  field :image, as: :file, as_avatar: :rounded, hide_on: [:index, :show, :edit, :new]

  # add fields here
end
