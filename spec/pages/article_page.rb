require 'page-object'

class ArticlePage
  include PageObject

  page_url 'http://localhost:9292/feed'

  link(:article_link, text: 'Article')
  h4(:header_temp, text: 'Contents')

  def click_article_tab
    article_link
  end
end
