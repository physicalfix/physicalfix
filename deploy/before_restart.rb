on_app_master do 
  sudo "monit monitor delayed_job"
  @rails_env = node[:environment][:framework_env]
  run "cd #{release_path} && whenever --update-crontab 'physicalfix' --set environment=#{@rails_env}"
end

run "ln -nfs /data/nginx/common/keep.servers.conf  /data/nginx/common/servers.conf"
