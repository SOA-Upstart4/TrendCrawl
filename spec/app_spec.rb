require_relative 'spec_helper'
require 'json'

describe 'Trend Crawl' do
  include PageObject::PageFactory

  before do
    unless @browser
      @headless = Headless.new
      @browser = Watir::Browser.new
    end
    @browser.goto 'localhost:9292'
  end

  describe 'Go to home page' do
    it 'finds title & header & three tabs & keywords area' do
      visit HomePage do |page|
        page.title.must_equal 'Explore with FirstGlance'
        page.execute_script("return (typeof arguments[0].naturalWidth!=\"undefined\" && arguments[0].naturalWidth>0)", page.header_img_element)
        page.trend_link_element.exists?.must_equal true
        page.article_link_element.exists?.must_equal true
        page.about_link_element.exists?.must_equal true
        page.keywords_header.must_equal 'Keywords'
        page.keywords_div_element.exists?.must_equal true
        page.plot_div_element.exists?.must_equal true
        @browser.ul(id: 'keyword_list').lis.length.must_equal 6
      end
    end

    it 'should add new keyword' do
      visit HomePage do |page|
        page.add_keyword('EC')

        @browser.ul(id: 'keyword_list').lis.length.must_equal 7
      end
    end

    it 'should delete a keyword' do
      visit HomePage do |page|
        page.delete_keword

        @browser.ul(id: 'keyword_list').lis.length.must_equal 5
      end
    end
  end

  describe 'Go to article_bs page' do
    it 'should show default message' do
      visit ArticlePage do |page|
        page.click_article_tab

        page.default_msg.must_equal "Sorry! We can't find the article."
      end
    end
  end
end
