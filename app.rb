require "sinatra"
require "sinatra/reloader" if development?

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