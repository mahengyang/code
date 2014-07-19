#!/usr/local/bin/env ruby

require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
 
Capybara.run_server = false
Capybara.current_driver = :webkit
Capybara.app_host = "http://www.google.com/"
 
module Spider 
  class Google
    include Capybara::DSL
 
    def search
    visit('/')
    fill_in "q", :with => ARGV[0] || "I love Ruby!" 
    click_button "Google Search"
    all("li.g h3").each do |h3| 
      a = h3.find("a")
      puts "#{h3.text}  =>  #{a[:href]}"
    end
    end
  end
end
 
spider = Spider::Google.new
spider.search