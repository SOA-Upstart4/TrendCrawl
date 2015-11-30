require_relative 'spec_helper'
require 'json'

describe 'Trend Crawl' do
  before do
    unless @browser
      @headless = Headless.new
      @browser = Watir::Browser.new
    end
    @browser.goto 'localhost:9292'
  end

  describe 'Go to home page' do
    it 'finds the title' do
      @browser.title.must_equal 'Explore with FirstGlance'
    end

    it 'finds the header' do
      @browser.h1.text.must_equal 'Explore with FirstGlance'
    end

    it 'has three tabs' do
      @browser.li(id: 'function_tab1').text.must_equal 'Trend'
      @browser.li(id: 'function_tab2').text.must_equal 'Article'
      @browser.li(id: 'function_tab3').text.must_equal 'About'
    end

    it 'finds keywords area' do
      @browser.h2.text.must_equal 'Keywords'
    end
  end

  describe 'Go to trend_bs page' do
    it 'show dashboard' do
      @browser.link(text: 'Trend').click

      @browser.h4.text.must_equal 'Dashboard'
    end
  end

  describe 'Go to article_bs page' do
    it 'show article' do
      @browser.link(text: 'Article').click

      @browser.h4.text.must_equal 'Contents'
    end
  end
end
