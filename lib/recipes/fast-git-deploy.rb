set :rolling_back, false
set :scm, :git
set :logged_user, Cap::Git::Deploy.current_user
set :branch, ENV['branch'] || Cap::Git::Deploy.current_branch unless exists? :branch
set(:latest_release) { fetch :current_path }

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

    # This is to make sure we are on the correct branch
    run "cd #{current_path}; git checkout -b #{branch} --track origin/#{branch}" if branch != 'master'
  end

  desc "Update the deployed code"
  task :update_code, :except => { :no_release => true } do
    # If we are rolling back branch is a commit
    branch_name = rolling_back && branch || "origin/#{branch}"

    run "cd #{current_path} && git fetch" unless rolling_back
    run "cd #{current_path} && git reset --hard #{branch_name}"
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

  desc "Create a REVISION file containing the SHA of the deployed commit"
  task :create_symlink, :except => { :no_release => true } do
    # If for some reason we cannot find the commit sha, then we'll use the branch name
    sha = "origin/#{branch}"
    run "cd #{current_path}; git rev-parse origin/#{branch}" do |channel, stream, data|
      sha = data.strip
    end

    commands = []
    commands << "cd #{current_path}"
    commands << "echo '#{sha}' > REVISION"
    commands << "echo '#{branch}' >> REVISION"
    commands << "echo '#{logged_user}' >> REVISION"
    commands << "echo '#{Time.now}' >> REVISION"
    run commands.join ' && '
  end

  task :symlink, :except => { :no_release => true } do
    create_symlink
  end

  task :migrate, :roles => :db, :only => { :primary => true } do
    rake = fetch :rake, "rake"
    bundler = fetch :bundler, "bundler"
    rails_env = fetch :rails_env, "production"
    migrate_env = fetch :migrate_env, ""

    run "cd #{current_path}; RAILS_ENV=#{rails_env} #{bundler} exec #{rake} db:migrate #{migrate_env}"
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    # Restart in Passenger way
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "Get info about last deploy"
task :get_revision do
  keys = %w(SHA Branch Author Date).reverse
  run "cat #{current_path}/REVISION" do |c, s, data|
    data.strip.lines.each do |line|
      puts "#{keys.pop}: #{line.strip}" if keys.any?
    end
  end
end

after 'deploy:update_code', 'deploy:migrate'