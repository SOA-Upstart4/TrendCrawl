require 'page-object'

class TrendPage
  include PageObject

  page_url 'http://localhost:9292/'

  link(:trend_link, text: 'Trend')
  div(:plot, id: 'plot')

  def click_trend_tab
    trend_link
  end
end
