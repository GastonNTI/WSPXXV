require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

get ('/') do
  redirect '/timer'
end

get ('/timer') do
  slim :timer
end