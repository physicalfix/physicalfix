run "rm #{config.release_path}/config/initializers/mongo_config.rb"
run "ln -nfs #{config.shared_path}/config/mongo_config.rb   #{config.release_path}/config/initializers/mongo_config.rb"
run "rm #{config.release_path}/config/s3.yml"
run "ln -nfs #{config.shared_path}/config/s3.yml #{config.release_path}/config/s3.yml"

on_app_master do 
  sudo "monit unmonitor delayed_job"
  sudo "pkill -9 -f 'Delayed'"
end
