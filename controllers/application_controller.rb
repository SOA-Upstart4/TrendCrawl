require 'sinatra/base'
require 'sinatra/flash'
# require 'chartkick' # Create beautiful Javascript charts with one line of Ruby
require 'rack-flash'
require 'httparty'
require 'slim'

require 'active_support'
require 'active_support/core_ext'

# Sinatra controller
class ApplicationController < Sinatra::Base
  use Rack::MethodOverride
  use Rack::Session::Pool
  use Rack::Flash
  register Sinatra::Flash # to be deleted
  helpers ApplicationHelpers

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure :production, :development do
    enable :logging
  end

  # Web functions
  get_root = lambda do
    slim :trend_bs
  end

  get_feed = lambda do
    @ranktype = params[:ranktype]
    if @ranktype
      redirect "/feed/#{@ranktype}"
      return nil
    end

    # slim :feed
    slim :article_bs
  end

  get_feed_ranktype = lambda do
    # TODO: Implement the function with Web APIs
    options = { headers: { 'Content-Type' => 'application/json' } }
    @rank = HTTParty.get(api_url("#{params[:ranktype]}"), options)
    logger.info api_url("#{params[:ranktype]}")
    if @rank.code != 200
      flash[:notice] = 'Getting rank error'
      redirect '/feed'
      return nil
    end

    if @rank.nil?
      flash[:notice] = 'no feed found'
      redirect '/feed'
      return nil
    end

    # slim :feed
    slim :article_bs
  end

  get_trend = lambda do
    @action = :create
    slim :trend
  end

  post_trend = lambda do
    form = TrendForm.new(params)

    error_send(back, "Following fields are required: #{form.error_fields}") \
      unless form.valid?

    results = GetTrendFromAPI.new(api_url('trend'), form).call

    if (results.code != 200)
      flash[:notice] = 'Could not process your request'
      redirect '/trend'
      return nil
    end

    session[:results] = results.to_json
    session[:action] = :create
    redirect "/trend/#{results.id}"
  end

  get_trend_id = lambda do
    if session[:action] == :create
      @results = JSON.parse(session[:results])
    else
      options =  { headers: { 'Content-Type' => 'application/json' } }
      @results = HTTParty.get(api_url("trend/#{params[:id]}"), options)
      if @results.code != 200
        flash[:notice] = 'Cannot find record'
        redirect '/trend'
      end
    end

    @id = params[:id]
    @action = :update
    @categories = @results['categories']
    slim :trend
  end

  delete_trend_id = lambda do
    HTTParty.delete api_url("trend/#{params[:id]}")
    flash[:notice] = 'record of trend deleted'
    redirect '/trend'
  end

  # Web App Views Routes
  get '/?', &get_root
  get '/feed/?', &get_feed
  get '/article/filter?', &get_article_by_viewid
  get '/feed/:ranktype/?', &get_feed_ranktype
  get '/trend/?', &get_trend
  post '/trend/?', &post_trend
  get '/trend/:id/?', &get_trend_id
  delete '/trend/:id/?', &delete_trend_id
end
