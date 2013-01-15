set :rolling_back, false
set :scm, :git
set :logged_user, Cap::Git::Deploy.current_user
unless exists? :branch
  set :branch, ENV['branch'] || Cap::Git::Deploy.current_branch
end
set(:latest_release) { fetch :current_path }
set(:current_release) { fetch :current_path }

namespace :deploy do
  desc "Setup a GitHub-style deployment"
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map do |shared_child|
      File.join shared_path, shared_child
    end
    run "mkdir -p #{dirs.join ' '} && chmod g+w #{dirs.join ' '}"
    run "git clone #{repository} #{current_path}"

    # This is where the log files will go
    run "mkdir -p #{current_path}/log" rescue 'no problem if log already exist'

    branch = fetch :branch, 'master'
    if branch != 'master'
      # This is to make sure we are on the correct branch
      run "cd #{current_path} && git checkout -b #{branch} --track origin/#{branch}"
    end
  end

  namespace :rollback do
    desc "Rollback to previous release"
    task :default, :except => { :no_release => true } do
      latest_tag = nil
      run "cd #{current_path}; git describe --tags --match deploy_* --abbrev=0 HEAD^" do |channel, stream, data|
        latest_tag = data.strip
      end

      if latest_tag
        set :branch, latest_tag
        set :rolling_back, true
        deploy::default
      else
        STDERR.puts "ERROR: Couldn't find tag to rollback to. Maybe you're already at the oldest possible tag?"
      end
    end
  end

  task :update, :except => { :no_release => true } do
    transaction do
      update_code
      insert_tag
    end
  end

  desc "Update the deployed code"
  task :update_code, :except => { :no_release => true } do
    # If we are rolling back branch, then this is a commit
    if rolling_back
      branch_name = branch
    else
      branch_name = "origin/#{fetch :branch, 'master'}"
    end

    run "cd #{current_path} && git fetch" unless rolling_back
    run "cd #{current_path} && git reset --hard #{branch_name}"

    finalize_update
  end

  task :insert_tag, :except => { :no_release => true } do
    timestamp = Time.now.strftime '%Y%m%d%H%M%S'
    run "cd #{current_path}; git tag deploy_#{timestamp}" unless rolling_back
  end
end

# launch bundle:install after update task if it's detected
# because it will not run with his standard behavior (before deploy:finalize_update)
# as we are using this custom git-style deployment procedure
after 'deploy:update', 'bundle:install' if find_task 'bundle:install'
