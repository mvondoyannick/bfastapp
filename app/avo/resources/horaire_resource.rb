class HoraireResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text, readonly: true, help: "Genéré automatiquement"
  field :departure, as: :time, name: "Heure de départ", picker_format: "H:i", relative: true, picker_options: { time_24hr: true }
  field :created_at, as: :date_time
  # add fields here
end
