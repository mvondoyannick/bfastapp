class ApiController < ActionController::API
  require "active_support/all"
  require "rake"
  # Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
  # Rails.Application.load_tasks # providing your application name is 'sample'
  before_action :read_url
  before_action :say_hello
  before_action :run

  private

  def read_url
    puts request.remote_ip
  end

  def say_hello
    puts "bonjour"
  end

  def journal
    @ip_address = request.remote_ip
    Rails::logger::info "Entering request"
    jrnal = journal.new(
      ip: @ip_address,
    )
    if jrnal.save
      puts "saved"
    else
      # send msg to admin
    end
  end

  def run
    # Rake::Task["me:update_feed"].reenable # in case you're going to invoke the same task second time.
    # Rake::Task["me:update_feed"].invoke
  end
end
