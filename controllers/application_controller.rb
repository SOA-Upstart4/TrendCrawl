require 'sinatra/base'
require 'sinatra/flash'
require 'chartkick' #Create beautiful Javascript charts with one line of Ruby

require 'httparty'
require 'hirb'
require 'hirb-unicode'
require 'slim'

require 'active_support'
require 'active_support/core_ext'

class ApplicationController < Sinatra::Base
  helpers ApplicationHelpers
  use Rack::Session::Pool
  use Sinatra::Flash
  use Rack::MethodOverride

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure :production, :development do
    enable :logging
  end

  # Web app views
  app_get_root = lambda do
    slim :home
  end

  app_get_feed = lambda do
    @ranktype = params[:ranktype]
    # @cat = params['cat'] if params.has_key? 'cat'
    # @page_no = params['page'] if params.has_key? 'page'
    if @ranktype
      redirect "/feed/#{@ranktype}"
      # To be included: redirect to get feeds in specific cat/page
      return nil
    end

    slim :feed
  end

  app_get_feed_ranktype = lambda do
    @ranktype = params[:ranktype]
    @cat = params['cat'] if params.has_key? 'cat'
    @page_no = params['page'] if params.has_key? 'page'
    @rank = get_ranks(@ranktype, @cat, @page_no)

    if @ranktype && @rank.nil?
      flash[:notice] = 'no feed found' if @rank.nil?
      redirect '/feed'
      return nil
    end

    slim :feed
  end

  app_get_trend = lambda do
    @action = :create
    slim :trend
  end

  app_post_trend = lambda do
    request_url = "#{settings.api_server}/#{settings.api_ver}/trend"
    categories = params[:categories]
    params_h = { categories: categories }

    options = {
      body: params_h.to_json,
      headers: { 'Content-Type' => 'application/json' }
    }

    result = HTTParty.post(request_url, options)

    if (result.code != 200)
      flash[:notice] = 'Could not process your request'
      redirect '/trend'
      return nil
    end

    id = result.request.last_uri.path.split('/').last
    session[:results] = result.to_json
    session[:action] = :create
    redirect "/trend/#{id}"
  end

  app_get_trend_id = lambda do
    if session[:action] == :create
      @results = JSON.parse(session[:results])
    else
      request_url = "#{settings.api_server}/#{settings.api_ver}/trend/#{params[:id]}"
      options =  { headers: { 'Content-Type' => 'application/json' } }
      @results = HTTParty.get(request_url, options)
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

  app_delete_trend_id = lambda do
    request_url = "#{settings.api_server}/#{settings.api_ver}/trend/#{params[:id]}"
    HTTParty.delete(request_url)
    flash[:notice] = 'record of trend deleted'
    redirect '/trend'
  end

  # To be added: app_get_trend, app_post_trend,app_get_trend_id, app_delete_trend_id

  # Web App Views Routes
  get '/?', &app_get_root
  get '/feed/?', &app_get_feed
  get '/feed/:ranktype/?', &app_get_feed_ranktype
  get '/trend/?', &app_get_trend
  post '/trend/?', &app_post_trend
  get '/trend/:id/?', &app_get_trend_id
  delete '/trend/:id/?', &app_delete_trend_id
  # To be added: get '/trend', post '/trend', get '/trend/:id', delete '/trend/:id'
end
