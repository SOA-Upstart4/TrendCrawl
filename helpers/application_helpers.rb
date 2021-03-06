require 'date'
require 'active_support/time'

module ApplicationHelpers
  API_BASE_URI = 'http://trendcrawl.herokuapp.com'
  # API_BASE_URI = 'http://bnext-dynamo.herokuapp.com'
  API_VER = '/api/v1/'

  def current_page?(path = ' ')
    path_info = request.path_info
    path_info += ' ' if path_info == '/'
    request_path = path_info.split '/'
    request_path[1] == path
  end

  def api_url(res)
    URI.join(API_BASE_URI, API_VER, res).to_s
  end

  def error_send(url, msg)
    flash[:notice] = msg
    redirect url
    halt 303        # http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
  end

  # Suggest the default keywords based on recent tags count
  def default_keywords(num_keywords)
    @lastweek = (Date.today - 7).strftime('%Y/%m/%d')
    options = { headers: { 'Content-Type' => 'application/json' },
                query: { date_from: @lastweek } }
    @open_url = HTTParty.get(api_url('article/filter'), options)
    @tags_count = {}
    @keywords = []

    # Count keywords in a hash indescending order
    @open_url.each do |article|
      @tag = JSON.parse(article['tags'])
      @tag.each do |tag|
        if @tags_count.key?(tag)
          @tags_count[tag] += 1
        else
          @tags_count.merge!(tag => 1)
        end
      end
    end
    @tags_count = Hash[@tags_count.sort_by { |_, v| -v }]
    # Extract keywords with highest fresquency
    for i in 0..num_keywords - 1
      @keywords << @tags_count.keys[i]
    end
    @keywords
  end

  # Show the according links in each keyword area
  def nav(tag, num)
    @tags = tag
    options = { headers: { 'Content-Type' => 'application/json' },
                query: { tags: @tags } }
    @open_url = HTTParty.get(api_url('article/filter'), options)
    @list = {}

    # Set the number of links to show for each keyword
    for i in 0..link_num(num) - 1
      viewid = @open_url[i]['link'][-5..-1] # Extract view id from article link
      article_url = '/article?viewid=' + viewid
      @list[@open_url[i]['title']] = article_url
    end
    @list
  end

  # Decide the amount of links to show on the navigators.
  def link_num(num_links)
    unless (@open_url.length) < num_links
      @link_num = num_links
    else
      @link_num = @open_url.length
    end
  end

  def add_keyword(keyword)
    options = { headers: { 'Content-Type' => 'application/json' },
                query: { tags: keyword } }
    @open_url = HTTParty.get(api_url('article/filter'), options)

    if session[:keywords].include? keyword
      flash[:notice] = 'Keyword already exists.'
    else
      unless @open_url.length == 0
        session[:keywords] << keyword
      else
        flash[:notice] = 'No matched articles. We cannot add this keyword.'
      end
    end

    redirect '/'
  end

  def del_keyword(keyword)
    session[:keywords].delete(keyword)
    redirect '/'
  end

  def count_article(tag, articles)
    ## get x-axis
    @categories = set_xaxis
    ## count data
    @keyword = tag
    @article = articles
    process_date_hash = {}
    @categories.each { |categorie| process_date_hash[categorie] = 0 }
    @article.each do |article|
      belong_which_month = Time.parse(article['date']).strftime('%Y/%m')
      if process_date_hash[belong_which_month] != nil
        process_date_hash[belong_which_month] += 1
      end
    end
    ## return value
    @count_data = {
      "keyword" => "#{@keyword}",
      "data" => process_date_hash.values
    }
  end

  ### init x-Axis
  def set_xaxis
    past_how_many_month = 12  # set default month
    @categories = past_how_many_month.times.map do |i|
      (Date.today - ((past_how_many_month - 1) - i).month).end_of_month.strftime('%Y/%m')
    end
    @categories
  end

  def dayrank_article
    @artc = []
    opt1 = { headers: { 'Content-Type' => 'application/json' } }
    @dayrank = HTTParty.get(api_url('dayrank'), opt1)

    @dayrank.each do |feed|
      @vid = feed['link'][-5..-1]
      opt2 = { headers: { 'Content-Type' => 'application/json' }, query: { :viewid => @vid } }
      @artc << HTTParty.get(api_url('article'), opt2)
    end
    @artc
  end
end
