class ApiController < ActionController::API
  require "active_support/all"
  before_action :read_url
  

  private
  def read_url
    puts request.remote_ip
  end
end