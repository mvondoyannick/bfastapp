Rails.application.routes.draw do
  devise_for :customers
  get 'main/index'
  get 'home/index'
  devise_for :users
  root :to => redirect('/avo')

  authenticate :user do
    mount Avo::Engine, at: Avo.configuration.root_path
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  scope :api, defaults: {format: :json}  do 
    scope :v1 do 
      # la mise en test et en developpement
      scope :sandbox do 
        get 'destination', to: 'main#ville_dest'
        post "geolocation", to: "main#geolocation"

        scope :auth do 
          post "login", to: "main#login"
        end

        scope :webhooks do 
          get 'webhook', to: "main#webhook"
        end

        scope :travels do 
          post "travel_entreprise", to: "main#travel_entreprise"
          post "travel_agences", to: "main#travel_agences"
        end

        scope :gazs do 
          post "list_gazs", to: "main#list_gazs"
          post "list_fournisseurs_gaz_bottle", to: "main#list_fournisseurs_gaz_bottle"
        end

        # scope market
        scope :market do 
          post "entreprises", to: "main#entreprises"
          post "search_entreprise", to: "main#search_entreprise"
          post "supermarches", to: "main#supermarches"
          post "products", to: "main#products"
          post "categories", to: "main#product_categories"
          post "rayons_products", to: "main#rayons_products"
          post "makeMarketPayment", to: "main#makeMarketPayment"
        end

        #scope travel
        scope :travel do 
          post "days_and_month", to: "main#days_and_month"
          post "hours_and_minutes", to: "main#hours_and_minutes"
          post 'makepayment', to: 'main#makepayment'
          post 'time', to: 'main#give_hours'
          post 'geolocation', to: "main#geolocate_this"

          # check if payment has been validated via OM or MOMO
          post 'check_paiement', to: "main#check_paiement"

          # security scope
          scope :security do
            post 'request_otp', to: 'main#request_otp'
          end

          # transaction and payment
          scope :payments do
            post 'register', to: "main#verify_otp" 
          end
        end
      end

      # la mise en production
      scope :prod do
      end
    end
  end
end
