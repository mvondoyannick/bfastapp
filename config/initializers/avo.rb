# For more information regarding these settings check out our docs https://docs.avohq.io
Avo.configure do |config|
  ## == Routing ==
  config.root_path = '/avo'

  # Where should the user be redirected when visting the `/avo` url
  # config.home_path = nil

  ## == Licensing ==
  config.license = 'pro' # change this to 'pro' when you add the license key
  config.license_key = "add29394-baf1-4c95-9453-15981cefd362"

  ## == Set the context ==
  config.set_context do
    {
      user: current_user,
      params: request.params,
      headers: request.headers
    }
    # Return a context object that gets evaluated in Avo::ApplicationController
  end

  ## == Authentication ==
  config.current_user_method = :current_user
  # config.authenticate_with = {}

  ## == Authorization ==
  # config.authorization_methods = {
  #   index: 'index?',
  #   show: 'show?',
  #   edit: 'edit?',
  #   new: 'new?',
  #   update: 'update?',
  #   create: 'create?',
  #   destroy: 'destroy?',
  # }
  # config.raise_error_on_missing_policy = false
  # config.authorization_client = :pundit

  ## == Localization ==
  config.locale = :fr

  ## == Resource options ==
  config.resource_controls_placement = :left
  # config.model_resource_mapping = {}
  # config.default_view_type = :table
  # config.per_page = 24
  # config.per_page_steps = [12, 24, 48, 72]
  # config.via_per_page = 8
  # config.id_links_to_resource = false
  # config.cache_resources_on_index_view = true
  ## permanent enable or disable cache_resource_filters, default value is false
  # config.cache_resource_filters = false
  ## provide a lambda to enable or disable cache_resource_filters per user/resource.
  # config.cache_resource_filters = ->(current_user:, resource:) { current_user.cache_resource_filters?}

  ## == Customization ==
  config.app_name = 'BFAST - DASHBOARD'
  # config.timezone = 'UTC'
  # config.currency = 'USD'
  # config.hide_layout_when_printing = false
  # config.full_width_container = false
  # config.full_width_index_view = false
  # config.search_debounce = 300
  # config.view_component_path = "app/components"
  # config.display_license_request_timeout_error = true
  # config.disabled_features = []
  # config.resource_controls = :right
  # config.tabs_style = :tabs # can be :tabs or :pills
  # config.buttons_on_form_footers = true
  # config.field_wrapper_layout = true

  ## == Branding ==
  config.branding = {
    colors: {
      background: "248 246 242",
      100 => "#fae8ff",
      400 => "#e879f9",
      500 => "#c026d3",
      600 => "#86198f",
    },
    chart_colors: ["#0B8AE2", "#34C683", "#2AB1EE", "#34C6A8"],
    # logo: "/avo-assets/logo.png",
    # logomark: "/avo-assets/logomark.png"
    # placeholder: "/avo-assets/placeholder.svg"
  }

  ## == Breadcrumbs ==
  config.display_breadcrumbs = true
  config.set_initial_breadcrumbs do
    add_breadcrumb "Home", '/avo'
  end

  ## == Menus ==
  config.main_menu = -> {
    section "Dashboards", icon: "dashboards" do
      all_dashboards
    end

    section "Markets", icon: "library", collapsable: true, collapsed: true do
      # all_resources
      group "Entreprises" do 
        resource :entreprise, label: "Entreprises"
        resource :distribution, label: "Supermarchés"
        resource :category, label: "Categorie produits"
      end

      group "activités" do 
        resource :product, label: "Produits"
      end
    end
    
    # gaz et produits petroliers
    section "Gaz & petrol", icon: "fire", collapsable: true, collapsed: true do
    end

    # points relais
    section "Points relais", icon: "map", collapsable: true, collapsed: true do 
    end

    # taxi via drive
    section "Taxi and drive", icon: "key", collapsable: true, collapsed: true do 
    end


    section "Travel", icon: "location-marker", collapsable: true, collapsed: true do
      # all_resources
      group "Entreprises" do 
        resource :travel_entreprise, label: "Entreprises"
        resource :travel_agence, label: "Agences"
      end

      group "activités" do 
        resource :reservation, label: "Reservation"
        resource :ville, label: "Ville"
        resource :bus, label: "Mes Bus"
        resource :horaire, label: "Mes horaires"
        resource :customer, label: "Passagers"
        resource :travel_transaction, label: "Transactions Travel"
      end
    end

    section "Foods & drinks", icon: "tools", collapsable: true, collapsed: true do
      resource :food, label: "Nourritures"
      resource :drink, label: "Boissons"
    end

    section "Tools", icon: "tools", collapsable: true, collapsed: true do
      all_tools
      resource :user, label: "Utilisateur & compte"
    end
  }
  config.profile_menu = -> {
    link "Profile", path: "/avo/profile", icon: "user-circle"
  }
end
