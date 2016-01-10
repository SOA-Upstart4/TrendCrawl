require 'page-object'

class ArticlePage
  include PageObject

  page_url 'http://localhost:9292/article'

  link(:article_link, text: 'Article')
  h2(:default_msg, text: 'Latest article selection')
  div(:article_div, id: 'three_default_article')

  h3(:article_title, id: 'title')
  h5(:article_author_date, id: 'author_date')
  link(:read_article_link, class: 'btn btn-success')

  def click_article_tab
    article_link
  end

  def click_read_article_button
    read_article_link
  end
end
