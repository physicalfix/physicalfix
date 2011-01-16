require 'rubygems'
require 'sinatra'

set :env, :production
disable :run, :reload

require 'vid2s3'
run Sinatra::Application