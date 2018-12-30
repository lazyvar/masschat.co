require "sinatra"
require "sinatra/activerecord"
require "sinatra/reloader" if development?

# configuration

set :database_file, "config/database.yml"

# models 

class MasschatUser < ActiveRecord::Base
    validates :username, uniqueness: true
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