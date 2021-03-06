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
    session[:keywords] ||= default_keywords(4)

    @added_word = params['added_word']
    @deleted_word = params['deleted_word']

    add_keyword(@added_word) if @added_word
    del_keyword(@deleted_word) if @deleted_word

    ## show trend line
    @data_count = []
    @categories = set_xaxis
    @tags = params['tags']
    @author = params['author']
    @title = params['title']

    for i in 0...session[:keywords].length
      @tags = session[:keywords][i]

      options = { headers: { 'Content-Type' => 'application/json' }, query: { :tags => @tags } }
      @article = HTTParty.get(api_url('article/filter?'), options)

      @data = count_article(@tags, @article)
      @data_count[i] = @data
    end

    slim :trend
  end

  get_article = lambda do
    session[:keywords] ||= default_keywords(6)
    @viewid = params['viewid']
    options = { headers: { 'Content-Type' => 'application/json' }, query: { :viewid => @viewid } }
    @article = HTTParty.get(api_url('article'), options)
     
    @card = dayrank_article

    slim :article
  end

  get_about = lambda do
    session[:keywords] ||= default_keywords(6)

    slim :about
  end

  # Web App Views Routes
  get '/?', &get_root
  get '/article/?', &get_article
  get '/about/?', &get_about
end
