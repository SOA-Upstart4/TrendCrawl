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
      end
    end
  end

  describe 'Go to trend_bs page' do
    it 'show dashboard' do
      @browser.link(text: 'Trend').click

      @browser.div(id: 'plot').present?.must_equal true
    end
  end

  describe 'Go to article_bs page' do
    it 'show article' do
      @browser.link(text: 'Article').click

      @browser.h4.text.must_equal 'Contents'
    end
  end
end
