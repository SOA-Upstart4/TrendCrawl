

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

  def right_nav(tag)
    @tags = tag
    options = { headers: { 'Content-Type' => 'application/json' }, query: { :tags => @tags } }
    @open_url = HTTParty.get(api_url('article/filter'), options)
    @list = {}
    for i in 0..4
      viewid = @open_url[i]['link'][-5..-1]
      article_url = '/article?viewid=' + viewid
      @list[@open_url[i]['title']] = article_url
    end
    @list
  end

  def add_keyword(keyword)
    session[:hot_keywords] << keyword 
    redirect '/'
  end

  def del_keyword(keyword)
    session[:hot_keywords].delete(keyword)
    redirect '/'
  end
end
