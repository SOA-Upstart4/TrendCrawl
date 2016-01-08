require 'page-object'

class ArticlePage
  include PageObject

  page_url 'http://localhost:9292/article'

  link(:article_link, text: 'Article')
  h3(:default_msg, text: "Sorry! We can't find the article.")

  def click_article_tab
    article_link
  end
end
