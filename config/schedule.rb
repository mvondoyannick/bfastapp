# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every 3.hours do
  # command "/usr/bin/some_great_command"
  # runner "MyModel.some_method"
  # rake "some:great:rake:task"
  rake 'update_feed'
end
every 4.days do
  # runner "AnotherModel.prune_old_records"
  puts '4 days'
end

# Learn more: http://github.com/javan/whenever
