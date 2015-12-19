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
    session[:hot_keywords] ||= ['Facebook', 'commerce', 'Paypal', 'eBay']
    # Keywords should change later

    @added_word = params['added_word']
    @deleted_word = params['deleted_word']

    add_keyword(@added_word) if @added_word 
    del_keyword(@deleted_word) if @deleted_word

    slim :trend
  end

  get_article_with_filter = lambda do
    @tags = params['tags']
    @author = params['author']
    @title = params['title']
    # @tags = 'Facebook'  #testing

    options = { headers: { 'Content-Type' => 'application/json' }, query: { :tags => @tags, :author => @author, :title => @title } }
    @article = HTTParty.get(api_url('article/filter'), options)

    if @article.nil?
      flash[:notice] = 'No matched articles.'
      redirect '/trend'
      return nil
    end

    slim :trend
  end

  get_article_by_viewid = lambda do
    @viewid = params['viewid']    
    # @viewid = '38036'  #testing
    options = { headers: { 'Content-Type' => 'application/json' }, query: { :viewid => @viewid } }
    @article = HTTParty.get(api_url('article'), options)

    if @article.code != 200
      flash[:notice] = 'Getteing article error.'
      redirect '/article'
      return nil
    end

    slim :article
  end

  # Web App Views Routes
  get '/?', &get_root
  get '/article/filter?', &get_article_with_filter
  get '/article/?', &get_article_by_viewid
end
