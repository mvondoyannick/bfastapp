class GazBottlesFournisseurResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  #field :id, as: :id
  # Fields generated from the model
  #field :gaz_fournisseur, as: :belongs_to
  #field :gaz_bottle, as: :belongs_to
  # add fields here
end
