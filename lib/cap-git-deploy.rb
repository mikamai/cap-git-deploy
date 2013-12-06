require 'capistrano'
require 'cap-git-deploy/version'

require 'etc'

module Cap
  module Git
    module Deploy
      # utility functions

      # The name of the branch we are deploying
      def self.current_branch
        repo = `git rev-parse --abbrev-ref HEAD`.chomp
      end

      # The name of the current logged user
      def self.current_user
        login = Etc.getlogin
        user  = Etc.getpwnam(login).gecos
        host  = Socket.gethostname
        "#{login}@#{host} (#{user})"
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.load_paths << File.join(File.dirname(__FILE__), "recipes")
  Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each do |f|
    Capistrano::Configuration.instance.load f
  end
end
