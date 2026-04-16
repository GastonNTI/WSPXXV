require_relative './model/model'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

include Model

enable :sessions

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

get ('/login') do
  slim :login
end

post ('/login') do
  username = params[:username]
  password = params[:password]
  
  if username.nil? || username.strip.empty? || password.nil? || password.strip.empty?
    @error = "Provide both username and password"
    return slim :login
  end
  
  db = SQLite3::Database.new("databas.db")
  user = db.execute('SELECT id, password_hash FROM accounts WHERE username = ?', [username]).first
  
  if user && BCrypt::Password.new(user[1]) == password
    session[:user_id] = user[0]
    session[:username] = username
    redirect '/timer'
  else
    @error = "Invalid username or password"
    slim :login
  end
end

post ('/logout') do
  session.clear
  redirect '/timer'
end

post ('/pause') do
  if session[:user_id]
    milliseconds = params[:milliseconds].to_i
    db = SQLite3::Database.new("databas.db")
    db.execute('INSERT INTO pause_times (user_id, milliseconds) VALUES (?, ?)',
               [session[:user_id], milliseconds])
    "OK"
  else
    halt 401, "Not logged in"
  end
end

get ('/pause-history') do
  if session[:user_id]
    db = SQLite3::Database.new("databas.db")
    @pause_times = db.execute('SELECT milliseconds, paused_at FROM pause_times WHERE user_id = ? ORDER BY paused_at DESC',
                              [session[:user_id]])
    slim :pause_history
  else
    redirect '/login'
  end
end

post ('/save-algorithm') do
  if session[:user_id]
    alg_name = params[:alg_name]
    alg_text = params[:alg_text]
    
    db = SQLite3::Database.new("databas.db")
    db.execute('INSERT OR REPLACE INTO algorithms (user_id, alg_name, alg_text, updated_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP)',
               [session[:user_id], alg_name, alg_text])
    "OK"
  else
    halt 401, "Not logged in"
  end
end

get ('/load-algorithm') do
  if session[:user_id]
    alg_name = params[:alg_name]
    db = SQLite3::Database.new("databas.db")
    result = db.execute('SELECT alg_text FROM algorithms WHERE user_id = ? AND alg_name = ?',
                        [session[:user_id], alg_name]).first
    if result
      {alg_text: result[0]}.to_json
    else
      {alg_text: nil}.to_json
    end
  else
    halt 401, "Not logged in"
  end
end