# Cap-Git-Deploy Changelog


## 0.1.2 2013-12-03

* don't depend on grit anymore
* include full user name inside the revision file


## 0.1.1 2013-11-12

* add support for submodules
* prune stale branches during `git fetch`


## 0.1.0 2013-11-11

* depend on capistrano 2 (avoid unwanted updates to capistrano 3)
* play shifted semver using `~> 0.1.0` as gem requirement
* bugfixes for deploy:setup
