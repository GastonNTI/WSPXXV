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

get ('/algorithm') do
  slim :algorithm
end

get ('/account') do
  slim :account
end

post ('/account') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  
  if password != password_confirm
    @error = "Passwords do not match"
    return slim :account
  end
  
  if username.nil? || username.strip.empty? || password.nil? || password.strip.empty?
    @error = "Provide both username and password"
    return slim :account
  end
  
  db = SQLite3::Database.new("databas.db")
  password_hash = BCrypt::Password.create(password)
  
  begin
    db.execute('INSERT INTO accounts (username, password_hash) VALUES (?, ?)',
               [username, password_hash])
    @success = "Account created! You can now login"
    slim :account
  rescue SQLite3::ConstraintException => e
    @error = "Username already exists"
    slim :account
  end
end