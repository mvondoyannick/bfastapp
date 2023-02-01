class GazBottleResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], amount_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  # Fields generated from the model
  field :image, as: :file, is_image: true, accept: "image/*"
  field :name, as: :text, link_to_resource: true
  field :modele, as: :select, options: {'12.5Kg': :'12.5', '25Kg': :'25'}, display_with_value: true, placeholder: "Selectionner un modele de bouteille", hide_on: [:edit, :show]
  field :modele, as: :text, hide_on: [:edit] do |model|
    "#{model.modele} Kg"
  end
  field :gaz_fournisseur, as: :belongs_to
  field :gaz_manufacturer, as: :belongs_to, name: "Fabriquant"
  field :amount, as: :text
  field :token, as: :textarea, readonly: true
  field :gaz_fournisseurs, as: :has_and_belongs_to_many
  # add fields here
end
