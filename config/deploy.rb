#############################################################
#	Application
#############################################################

set :application, "physicalfix.com"
set :deploy_to, "/webapps/#{application}"
set :db_type, "mysql"

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
set :use_sudo, true

#############################################################
#	Servers
#############################################################

set :user, "podman"
set :domain, "75.101.157.90"
role :web, domain
role :app, domain
role :db, domain, :primary => true

#############################################################
#	Subversion
#############################################################

set :repository,  "git@github.com:podman/physicalfix.git"
set :scm, :git
set :scm_user, "podman"
set :branch, "master"
set :deploy_via, :remote_cache
set :scm_verbose, true

#############################################################
#	Passenger
#############################################################

namespace :deploy do
  task :restart, :roles => :app do
    sudo "touch #{current_path}/tmp/restart.txt"
  end
  
  task :start, :roles => :app do
    sudo "/etc/init.d/nginx restart"
  end
  
  task :update_crontab, :roles => :app do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
  
  task :update_gems, :roles => :app do
    run "cd #{release_path} && rake gems:install"
  end
end

namespace :db do
  desc "Runs rake db:create on remote server"
  task :create do
    run "cd #{current_path} && RAILS_ENV=production rake db:create"
  end
end

namespace :assets do
  task :symlink, :roles => :app do
    sudo "mkdir -p #{shared_path}/workout_notes"
    sudo "rm -rf #{release_path}/public/workout_notes"
    sudo "ln -nfs #{shared_path}/workout_notes #{release_path}/public/workout_notes"
  end
end


after "deploy:update_code", "deploy:update_gems"
after "deploy:update_gems", "deploy:update_crontab"
after "deploy:update_crontab", "assets:symlink"

before "deploy:migrate", "db:create"

after "deploy", "deploy:cleanup"
