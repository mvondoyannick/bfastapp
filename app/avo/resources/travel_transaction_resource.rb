class TravelTransactionResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :amount, as: :text
  field :reference, as: :text
  field :tstatus, as: :text
  field :currency, as: :text
  field :operator, as: :text
  field :code, as: :text
  field :external_reference, as: :text
  # add fields here
end
