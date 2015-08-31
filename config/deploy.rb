# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'gpCollect'
set :repo_url, 'git@github.com:misch/gpCollect'

set :services, [:thin]
require 'capistrano/service'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/opt/webapps/gpCollect'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('.env')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('public/assets')
# .push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  # Clear existing task so we can replace it rather than "add" to it.
  #Rake::Task["deploy:compile_assets"].clear

  desc "Precompile assets locally and then rsync to web servers"
  task :compile_assets_locally do
    on roles(:app) do |host|
      execute "mkdir -p #{shared_path}/public/"
      run_locally do
        with rails_env: :production do ## Set your env accordingly.
          execute  "bundle exec rake assets:precompile"
        end
        execute "rsync -av --delete ./public/assets/ #{host.user}@#{host}:#{shared_path}/public/assets/"
        execute "rm -rf public/assets"
        # execute "rm -rf tmp/cache/assets" # in case you are not seeing changes
      end
    end
  end

  after :finished, :compile_assets_and_restart do
    on roles(:all) do
      deploy.compile_assets_locally
      service.thin.restart
      within release_path do
        execute :rake, 'tmp:clear'
      end
    end
  end
end

