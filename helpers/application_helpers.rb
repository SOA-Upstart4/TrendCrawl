require 'date'

module ApplicationHelpers
  API_BASE_URI = 'http://trendcrawl.herokuapp.com'
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
    flash[:error] = msg
    redirect url
    halt 303        # http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
  end

  # Suggest the default keywords based on recent tags count
  def default_keywords(num_keywords)
    @lastweek = (Date.today - 7).strftime('%Y/%m/%d')
    options = { headers: { 'Content-Type' => 'application/json' }, query: { :date_from => @lastweek } }
    @open_url = HTTParty.get(api_url('article/filter'), options)
    @tags_count = {}
    @keywords = []
    
    for i in 0..@open_url.length - 1
      @tag = JSON.parse(@open_url[i]['tags'])
      for k in 0..@tag.length - 1
        if @tags_count.has_key?(@tag[k])
          @tags_count[@tag[k]] += 1
        else
          @tags_count.merge!(@tag[k] => 1)
        end
      end
    end
    
    @tags_count = Hash[@tags_count.sort_by{ |_, v| -v }]
    
    for i in 0..num_keywords-1
      @keywords << @tags_count.keys[i]
    end

    @keywords
  end

  # Show the according links in each keyword area
  def right_nav(tag)
    @tags = tag
    options = { headers: { 'Content-Type' => 'application/json' }, query: { :tags => @tags } }
    @open_url = HTTParty.get(api_url('article/filter'), options)
    @list = {}

    @n = link_num(5) - 1 # Set the number of links to show for each keyword

    for i in 0..@n
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
    options = { headers: { 'Content-Type' => 'application/json' }, query: { :tags => keyword } }
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
    # session[:data].delete()
    redirect '/'
  end

  def count_article(tag, articles)
    @keyword = tag
    @article = articles
    @count_data = {
      "keyword" => "#{@keyword}",
      "data" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }
    for i in 0...@article.length
      article_belong_which_month = Time.parse(@article[i]['date']).strftime('%m').to_i
      @count_data['data'][article_belong_which_month - 1] += 1
    end
    @count_data
  end
end
