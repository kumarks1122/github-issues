server "128.199.95.115", :app, :web, :db, :primary => true
set :deploy_to, "/var/www/ugc/"
set :branch, 'development'
set :scm_verbose, true
set :use_sudo, false
set :rails_env, "development" #added for delayed job 
set :rvm_type, :system


after 'deploy:update_code' do
  # run "cd #{release_path}; RAILS_ENV=production rake assets:precompile"
  run "cd #{release_path};"
  
  run "rm -rf #{release_path}/tmp"
  run "ln -s #{shared_path}/system/tmp #{release_path}"

  run "rm -rf #{release_path}/public/system"
  run "ln -s #{shared_path}/system/ #{release_path}/public/" 
  
  run "ln -s #{shared_path}/feeds/ #{release_path}/public/" 

  run "rm -rf #{release_path}/public/uploads"
  run "ln -s #{shared_path}/uploads  #{release_path}/public/"

  run "cd #{release_path} && bundle install"
  run "mv #{release_path}/config/database.sample.yml  #{release_path}/config/database.yml"
  run "mv #{release_path}/config/sunspot.sample.yml  #{release_path}/config/sunspot.yml"
  # run "mv #{release_path}/config/database.example.test.yml  #{release_path}/config/database.yml"
  
  # run "export PRERENDER_SERVICE_URL='http://fundsinn.com:3000/'"
  run "chown -R www-data:www-data /var/www/"
  run "cd #{release_path} && chmod u+x bin/rails"
  # chown -R www-data:www-data /var/www/
  # run "cd #{release_path} && rake db:create"
  run "cd #{release_path} && RAILS_ENV=development rake db:migrate"
  run "cd #{release_path} && RAILS_ENV=development rake sunspot:solr:start"
  #run "cd #{release_path} && RAILS_ENV=development rake sunspot:solr:reindex"
  run "cd #{release_path} && RAILS_ENV=development rake assets:precompile"
  run "cd #{shared_path} && chmod -R 777 system/*"
  run "cd #{shared_path} && chmod -R 777 system/tmp"
end

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end