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

  describe 'Go to about page' do
    it 'should show information' do
      visit AboutPage do |page|
        page.bnext_link_element.enabled?.must_equal true
        page.home_link_element.exist?.must_equal true
        page.iss_link_element.exist?.must_equal true
        page.github_link_element.exist?.must_equal true
      end
    end
  end
=begin
  describe 'Go to home page' do
    it 'finds title & header & three tabs & keywords area' do
      # GIVEN
      visit HomePage do |page|
        # THEN
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
      # GIVEN
      visit HomePage do |page|
        # WHEN
        page.add_keyword('EC')

        # THEN
        @browser.ul(id: 'keyword_list').lis.length.must_equal 7
      end
    end

    it 'should delete a keyword' do
      # GIVEN
      visit HomePage do |page|
        # WHEN
        page.delete_keword

        # THEN
        @browser.ul(id: 'keyword_list').lis.length.must_equal 5
      end
    end
  end

  describe 'Go to article page' do
    it 'should show default three articles' do
      # GIVEN
      visit ArticlePage do |page|
        # WHEN
        page.click_article_tab

        # THEN
        page.default_msg.must_equal 'Latest article selection'
        page.article_div_element.exists?.must_equal true
        @browser.div(id: 'three_default_article').images.size.must_equal 3
      end
    end

    it 'should show article content' do
      # GIVEN
      visit ArticlePage do |page|
        # WHEN
        page.click_read_article_button

        # THEN
        page.article_title_element.exists?.must_equal true
        page.article_author_date_element.exists?.must_equal true
      end
    end
  end
=end
end
