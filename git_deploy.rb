set :rolling_back, false

namespace :deploy do
  desc "Deploy the MFer"
  task :default do
    update
    restart
  end
  
  desc "Setup a GitHub-style deployment."
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "git clone #{repository} #{current_path}"
    
    # This is where Mongrel will save its .pid files
    run "#{try_sudo} mkdir -p #{current_path}/tmp/pids"
    
    # This is where the log files will go
    run "#{try_sudo} mkdir -p #{current_path}/log"
    
    # This is to make sure we are on the correct branch
    run "cd #{current_path}; git checkout -b #{branch} --track origin/#{branch}" unless branch == 'master'
  end
 
  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git pull origin #{branch};" unless rolling_back
    run "cd #{current_path}; git reset --hard #{branch}"
    
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    run "cd #{current_path}; git tag deploy_#{timestamp}" unless rolling_back
  end
  
  namespace :rollback do
    desc "Rollback to previous release"
    task :default, :except => { :no_release => true } do
      latest_tag = ""
      run "cd #{current_path}; git describe --tags --match deploy_* --abbrev=0 HEAD^" do |channel, stream, data|
        latest_tag << data.strip
      end
      
      if latest_tag.empty?
        STDERR.puts "ERROR: Couldn't find tag to rollback to. Maybe you're already at the oldest possible tag?"
      else
        set :branch, latest_tag
        set :rolling_back, true
        deploy::default
      end
    end
  end
  
  task :symlink, :except => { :no_release => true } do
    # This empty task is needed to override the default :symlink task
  end
  
  task :migrate, :roles => :db, :only => { :primary => true } do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    migrate_env = fetch(:migrate_env, "")
    
    run "cd #{current_path}; #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:migrate"
  end
  
end
