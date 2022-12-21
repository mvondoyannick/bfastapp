class UserResource < Avo::BaseResource
  self.title = :email
  self.description = "Compte utilisateur"
  self.devise_password_optional = true
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], email_cont: params[:q], name_cont: params[:q], second_name_cont: params[:q], phone_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  # Fields generated from the model
  field :email, as: :text, name: "Adresse email", required: true
  field :name, as: :text, name: "Nom"
  field :second_name, as: :text, name: "Prénom"
  field :phone, as: :text, name: "Numéro de télephone"
  field :sexe, as: :select, options: {'Masculin': 'masculin', 'Féminin': 'feminin'}
  field :password, as: :password
  # add fields here
end
