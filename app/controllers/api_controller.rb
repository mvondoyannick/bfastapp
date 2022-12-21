class ApiController < ActionController::API
  before_action :read_url
  

  private
  def read_url
    puts request.remote_ip
  end
end