require 'page-object'

class HomePage
  include PageObject

  page_url 'http://localhost:9292/'

  link(:trend_link, text: 'Trend')
  link(:article_link, text: 'Article')
  link(:about_link, text: 'About')
  image(:header_img, id: 'header')
  h3(:keywords_header, text: 'Keywords')
  div(:keywords_div, class: 'col-sm-3')
  div(:plot_div, id: 'plot')
  text_field(:search_keyword, id: 'add_keyword_side')
  button(:search_button, id: 'search')
  button(:delete_button, id: 'delete_first')
  unordered_list(:key, id: 'keyword_list')

  def add_keyword(keyword)
    search_keyword_element.append(keyword)
    search_button
  end

  def delete_keword
    delete_button
  end
end
