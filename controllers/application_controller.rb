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
    slim :trend
  end

  get_article_with_filter = lambda do
    @tags = params['tags'] if params.has_key? 'tags'
    @title = params['title'] if params.has_key? 'title'
    @author = params['author'] if params.has_key? 'author'
    @article = find_articles(@tags, @title, @author)

    if @article.nil?
      flash[:notice] = 'No matched articles.'
      redirect '/trend'
      return nil
    end

    slim :trend
  end

  get_article_by_viewid = lambda do
    options = { headers: { 'Content-Type' => 'application/json' } }
    @article = HTTParty.get(api_url("/article/view/id/#{params[:viewid]}"), options)
    if @article.code != 200
      flash[:notice] = 'Getteing article error.'
      redirect '/article'
      return nil
    end

    if @article.nil?
      flash[:notice] = 'No article found.'
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
