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

# routes

get '/' do
    send_file File.join(settings.public_folder, 'index.html')
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
    
    redirect '/'
end

get '/login' do

end

post '/login' do

end

get 'logout' do

end