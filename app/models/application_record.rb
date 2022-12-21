class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # url_for helper
  include Rails.application.routes.url_helpers

  # ensure rqrcode works here
  require "rqrcode"
end
