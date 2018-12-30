require "sinatra"
require "sinatra/activerecord"
require "sinatra/reloader" if development?

# configuration

set :database_file, "config/database.yml"
enable :sessions

# models 

class MasschatUser < ActiveRecord::Base
    validates :username, uniqueness: true
    has_secure_password
end

# helpers

helpers do
    def current_user
      if session[:current_user_id]
        MasschatUser.find(session[:current_user_id])
      else
        nil
      end
    end
end

# routes

get '/' do
    puts current_user
    puts session[:current_user_id]
    erb :index
end

get '/search' do
    query = URI.escape(params[:q])

    redirect "/!/#{query}"
end

get '/!/:query' do
    query = params[:query]

    erb :query, :locals => {:query => query}
end

get '/signup' do
    erb :signup
end

post '/signup' do
    username = params[:username]
    password = params[:password]
    confirm_password = params[:confirm_password]

    if username.empty? || password.empty? || confirm_password.empty?
        # hiting the API not through the HTML form...
        return erb :signup
    end

    if password != confirm_password
        status 400
        return erb :signup, :locals => {:error_message => 'Passwords do not match'}
    end

    if password.length < 6
        status 400
        return erb :signup, :locals => {:error_message => 'Password must be at least 6 characters'}
    end

    user = MasschatUser.new(username: username, password: password)

    begin
        user.save!
    rescue => exception
        status 400
        return erb :signup, :locals => {:error_message => exception.message}
    end

    session[:current_user_id] = user.id

    redirect '/'
end

get '/login' do
    erb :login
end

post '/login' do
    username = params[:username]
    password = params[:password]

    if username.empty? || password.empty?
        # hiting the API not through the HTML form...
        return erb :login
    end

    user = MasschatUser.find_by(username: username)

    if user && user.authenticate(password)
        session[:current_user_id] = user.id
        redirect '/'
    else
        erb :login, :locals => {:error_message => "Nope"}
    end
end

get '/logout' do
    session[:current_user_id] = nil
    redirect '/'
end