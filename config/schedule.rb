# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :cron_log, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every :monday, :at => '7am' do
  runner 'User.send_reminders'
end

# Could create a new rake task to handle this too
# 11:05:07 AM Adam Podolnick: maybe just create a new rake task for daily activities, like checking subscriptions over the trial, sending out reminders, etc
# 11:05:19 AM Adam Podolnick: and change the schedule.rb to call that instead
every 1.day, :at => '7am' do
  runner 'User.send_nag_emails'
  runner 'User.check_expired_trials'
end
