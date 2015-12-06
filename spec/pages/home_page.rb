require 'page-object'

class HomePage
  include PageObject

  page_url 'http://localhost:9292/'

  link(:trend_link, text: 'Trend')
  link(:article_link, text: 'Article')
  link(:about_link, text: 'About')
  image(:header_img, id: 'header')
  h2(:keywords_header, text: 'Keywords')
  div(:keywords_div, class: 'col-sm-3')
end
