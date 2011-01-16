run "rm #{release_path}/config/initializers/mongo_config.rb"
run "ln -nfs #{shared_path}/config/mongo_config.rb   #{release_path}/config/initializers/mongo_config.rb"

on_app_master do 
  sudo "monit unmonitor delayed_job"
  sudo "pkill -9 -f 'Delayed'"
end
