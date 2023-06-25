# set :environment, "development"
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 10.seconds do
#   # command "/usr/bin/some_great_command"
#   # runner "MyModel.some_method"
#   # rake "some:great:rake:task"
#   # rake 'update_feed'
#   File.open("out.txt", "w") do |f|
#     f.write("lorem")
#   end
# end
every :hour do
  rake "me:manage_photo"
end

# every :hour, roles: [:app] do
#   rake "me:update_feed"
# end

every :day, at: "8:30 am" do
  rake "me:say_good_morning"
end

every :day, at: ["09:00 AM", "12:00 AM", "3:00 PM", "6:00 PM"] do
  rake "me:update_feed"
end

every :day, at: ["6:00 PM"] do
  rake "me:send_statistics"
end

# Learn more: http://github.com/javan/whenever
