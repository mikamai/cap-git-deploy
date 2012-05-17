require 'capistrano'
require "cap-git-deploy/version"

require 'grit'
require 'etc'

module Cap
  module Git
    module Deploy
      # utility functions

      def self.current_branch
        repo = Grit::Repo.new '.'
        branch = repo.head
        # if branch is nil, we are in a spurius commit, then we should use master
        branch && branch.name || 'master'
      end

      def self.current_user
        "#{Etc.getlogin}@#{Socket.gethostname}"
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