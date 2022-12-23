class TravelTransactionResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :reservation, as: :belongs_to
  # Fields generated from the model
  field :amount, as: :text
  field :reference, as: :text
  field :tstatus, as: :text
  field :currency, as: :text, hide_on: [:index]
  field :operator, as: :text
  field :code, as: :text, hide_on: [:index]
  field :external_reference, as: :text, hide_on: [:index]
  # add fields here
end
