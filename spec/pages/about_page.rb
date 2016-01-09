require 'page-object'

class AboutPage
  include PageObject

  page_url 'http://localhost:9292/about'

  link(:bnext_link, href: 'http://www.bnext.com.tw')
  link(:home_link, href: '/')
  link(:iss_link, href: 'http://www.iss.nthu.edu.tw/')
  link(:github_link, href: 'https://github.com/SOA-Upstart4')
end
