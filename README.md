# Installation

```bash
    gem install cap-git-deploy
```

or inside your Gemfile:

```ruby
    group :development do
      gem 'cap-git-deploy'
    end
```

# How to use

cap-git-deploy disables the use of the symlinks for version control in favor of a tag-style mechanism with git: every deploy is marked with a git tag. A rollback is a checkout to a tag.

The following is a sample recipe that uses git-deploy as deployment procedure:

```ruby
    require 'cap-git-deploy'

    set :repository, 'git@my-host.com:my-app.git'
    set :deploy_to, '/var/apps/my-app'
    role :app, 'my-host.com'
    role :web, 'my-host.com'
    role :db, 'my-host.com'
```

In addition, cap-git-deploy stores some deploy info inside a revision file (called REVISION by default) on the remote host.
After each deploy the commit sha, the branch name, the user name and the current date are stored inside this file.
To show the deploy infos you can launch the revision:get task:

```bash
    cap revision:get
```

## Note: Current Branch

By default, your current branch will be deployed.
However, when working with staging environments, usually you want to deploy a particular branch unless specified. In this case insert the following in your deploy.rb file:

```ruby
    set :branch, ENV['branch'] || 'master'
```

In this way, 'cap deploy' will deploy the 'master' branch, instead 'cap deploy branch=foo' will deploy the branch 'foo'.

For production environments **you should** use something like the following code:

```ruby
    set :branch, 'master'
```

## Note: Setup

To setup your environment, when your recipes are ready, type the following command from your rails app:

```bash
    cap deploy:setup
```

This will setup your git repository on the remote host.

## Other Stuff: Logs

Tail the current environment log with the "logs" task. So the following command will do a "tail -F" on "log/beta.log"

```bash
    cap beta logs
````
