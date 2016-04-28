# load deps and kickstart the app
require 'rubygems'
# require 'bundler/setup'

require 'joyce'
require_relative 'lib/application'

Example::Application.kickstart!
