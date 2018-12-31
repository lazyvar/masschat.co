require "sinatra"
require "sinatra/activerecord"
require "sinatra/reloader" if development?
require 'twilio-ruby'

twilio_sid = ENV['masschat_twilio_sid']
twilio_auth_token = ENV['masschat_twilio_auth_token']

twilio_client = Twilio::REST::Client.new twilio_sid, twilio_auth_token

# configuration

set :database_file, "config/database.yml"
enable :sessions

# models 

class MasschatUser < ActiveRecord::Base
    validates :username, uniqueness: true
    validates :phonenumber, uniqueness: true

    has_many :posts
    has_many :votes

    def display_name
        "@#{username}"
    end
end

class Post < ActiveRecord::Base
    belongs_to :masschat_user
    has_many :votes

    def score
        votes.where(up: true).length - votes.where(up: false).length
    end

    def display
        unless title.nil? || title.empty?
            title
        else
            url
        end
    end
end

class Vote < ActiveRecord::Base
    belongs_to :masschat_user
    belongs_to :post
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

    def post_selected_classname(post, up)
        voted_up = current_user_voted_up(post)
        unless voted_up.nil?
            voted_up == up ? "selected" : ""
        else 
            ""
        end
    end

    def current_user_voted_up(post)
        if current_user
            vote = post.votes.find_by(masschat_user_id: current_user.id)
            if vote
                vote.up
            else
                nil
            end
        else
            nil
        end
    end

end

# routes

get '/' do
    erb :index
end

get '/search' do
    q = params[:q].strip
    query = URI.escape(q)

    redirect "/!/#{query}"
end

get '/!/' do
    redirect "/"
end

get '/!/:query' do
    query = params[:query].strip

    posts = Post.where(query: query)
    posts = posts.sort { |a,b| b.score <=> a.score }
    
    erb :query, :locals => {:query => query.strip, :posts => posts.first(20)}
end

get '/add' do
    unless current_user
        return redirect '/'
    end

    q = params[:q] || ""

    erb :add_link, :locals => {:query => q.strip}
end

post '/add' do
    query = params[:query].strip
    url = params[:url]
    title = params[:title]

    unless url.start_with?("http://") || url.start_with?("https://")
        url = "http://#{url}"
    end
    
    existing_post = Post.find_by(query: query, url: url)

    if existing_post
        return erb :add_link, :locals => {:query => query, :error_message => "The link '#{url}' has already been added for '#{query}'"}
    end

    post = Post.new
    post.masschat_user_id = current_user.id
    post.url = url
    post.query = query
    post.title = title
    post.save

    query = URI.escape(query)

    redirect "/!/#{query}"
end

post '/vote' do  
    payload = JSON.parse request.body.read

    post_id = payload['post_id'].to_i
    up = payload['up']

    vote = Vote.find_by(post_id: post_id, masschat_user_id: current_user.id) || Vote.new
    vote.up = up
    vote.post_id = post_id
    vote.masschat_user_id = current_user.id
    vote.save!
    
    "success"
end

get '/signup' do
    if current_user
        return redirect '/'
    end

    erb :signup
end

post '/signup' do
    username = params[:username]
    phonenumber = params[:phonenumber]

    if username.empty? || phonenumber.empty?
        # hiting the API not through the HTML form...
        return erb :signup
    end

    begin
        number = twilio_client.lookups.phone_numbers(phonenumber).fetch.phone_number
    rescue => exception
        return erb :signup, :locals => {:error_message => 'Invalid phone number'}         
    end

    if MasschatUser.find_by(username: username) || MasschatUser.find_by(phonenumber: number)
        return erb :signup, :locals => {:error_message => 'User with that info already exists'}
    end

    code = rand(1000..9999)

    begin
        twilio_client.api.account.messages.create(
            from: '+14848813811',
            to: number,
            body: "Your login code for Masschat is #{code}"
        )
    rescue => exception
        return erb :signup, :locals => {:error_message => 'Error sending message, please try again'}         
    end

    session[:signup_code] = code
    session[:signup_username] = username
    session[:signup_phonenumber] = number

    redirect '/signup-confirm-phone'
end

get '/signup-confirm-phone' do
    if current_user
        return redirect '/'
    end

    erb :signup_confirm_phone
end

post '/signup-confirm-phone' do
    code_confirmation = params[:code]
    code = session[:signup_code].to_s
    username = session[:signup_username]
    phonenumber = session[:signup_phonenumber]

    if code != code_confirmation
        return erb :signup_confirm_phone, :locals => {error_message: "That code does not match"}
    end

    user = MasschatUser.create(username: username, phonenumber: phonenumber)

    session[:signup_code] = nil
    session[:signup_username] = nil
    session[:signup_phonenumber] = nil

    session[:current_user_id] = user.id

    redirect '/'
end

get '/login' do
    if current_user
        return redirect '/'
    end

    erb :login
end

post '/login' do
    phonenumber = params[:phonenumber]

    if phonenumber.empty?
        # hiting the API not through the HTML form...
        return erb :login
    end

    begin
        number = twilio_client.lookups.phone_numbers(phonenumber).fetch.phone_number
    rescue => exception
        return erb :login, :locals => {:error_message => 'Invalid phone number'}         
    end

    user = MasschatUser.find_by(phonenumber: number)

    if user.nil?
        return erb :login, :locals => {:error_message => 'Invalid phone number'}
    end
        
    code = rand(1000..9999)

    begin
        twilio_client.api.account.messages.create(
            from: '+14848813811',
            to: number,
            body: "Your login code for Masschat is #{code}"
        )
    rescue => exception
        return erb :login, :locals => {:error_message => 'Error sending message, please try again'}         
    end

    session[:login_code] = code
    session[:login_user_id] = user.id

    redirect '/login-confirm-phone'
end

get '/login-confirm-phone' do
    if current_user
        return redirect '/'
    end

    erb :login_confirm_phone
end

post '/login-confirm-phone' do
    code_confirmation = params[:code]
    code = session[:login_code].to_s
    login_user_id = session[:login_user_id]

    if code != code_confirmation
        return erb :login_confirm_phone, :locals => {error_message: "That code does not match"}
    end

    session[:login_code] = nil
    session[:login_user_id] = nil

    session[:current_user_id] = login_user_id

    redirect '/'
end

get '/logout' do
    session[:current_user_id] = nil
    redirect '/'
end