class HoraireResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text
  field :amount, as: :number, required: true
  field :departure, as: :date_time
  field :created_at, as: :date_time
  field :food, as: :belongs_to 
  field :drink, as: :belongs_to
  field :buses, as: :has_many
  field :bus, as: :belongs_to
  # add fields here
end
