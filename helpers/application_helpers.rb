

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

  # Show the according links in each keyword area
  def right_nav(tag)
    @tags = tag
    options = { headers: { 'Content-Type' => 'application/json' }, query: { :tags => @tags } }
    @open_url = HTTParty.get(api_url('article/filter'), options)
    @list = {}

    @n = link_num(5) - 1

    for i in 0..@n
      viewid = @open_url[i]['link'][-5..-1] # Extract view id from article link
      article_url = '/article?viewid=' + viewid
      @list[@open_url[i]['title']] = article_url
    end
    @list
  end

  # Decide the amount of links to show.
  def link_num(num)
    unless (@open_url.length) < num
      @link_num = num
    else
      @link_num = @open_url.length
    end
  end

  def add_keyword(keyword)
    options = { headers: { 'Content-Type' => 'application/json' }, query: { :tags => keyword } }
    @open_url = HTTParty.get(api_url('article/filter'), options)

    if session[:hot_keywords].include? keyword
      flash[:notice] = 'Keyword already exists.'
    else
      unless @open_url.length == 0
        session[:hot_keywords] << keyword 
      else
        flash[:notice] = 'No matched articles. We cannot add this keyword.'
      end
    end

    redirect '/'
  end

  def del_keyword(keyword)
    session[:hot_keywords].delete(keyword)
    redirect '/'
  end
end
