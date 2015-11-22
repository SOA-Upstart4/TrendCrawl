require 'sinatra/base'
require 'sinatra/flash'
require 'chartkick' # Create beautiful Javascript charts with one line of Ruby

require 'httparty'
require 'slim'

require 'active_support'
require 'active_support/core_ext'

class ApplicationController < Sinatra::Base
  helpers ApplicationHelpers
  use Rack::Session::Pool
  register Sinatra::Flash
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
    form = TrendForm.new(params)
    error_send(back, "Following fields are required: #{form.error_fields}") \
      unless form.valid?

    result = GetTrendFromAPI.new(trend_api_url('trend'), form).call
    error_send back, 'Could not process your request' if (result.code != 200)

    session[:results] = result
    redirect "/trend/#{result.id}"
  end

  app_get_trend_id = lambda do
    if session[:action] == :create
      @results = JSON.parse(session[:results])
    else
      request_url = trend_api_url "trend/#{params[:id]}"
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
    request_url = trend_api_url "trend/#{params[:id]}"
    HTTParty.delete(request_url)
    flash[:notice] = 'record of trend deleted'
    redirect '/trend'
  end

  # Web App Views Routes
  get '/?', &app_get_root
  get '/feed/?', &app_get_feed
  get '/feed/:ranktype/?', &app_get_feed_ranktype
  get '/trend/?', &app_get_trend
  post '/trend/?', &app_post_trend
  get '/trend/:id/?', &app_get_trend_id
  delete '/trend/:id/?', &app_delete_trend_id
end
