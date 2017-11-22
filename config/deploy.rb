# config valid for current version and patch releases of Capistrano
lock "~> 3.10.0"

set :application, 'bta-site'

set :repo_url, 'git@github.com:bmoretransalliance/bta-site.git'

set :deploy_to, '/home/deploy/bta-site'

set :ssh_options, { :forward_agent => true }

set :repo_tree, '_site'
