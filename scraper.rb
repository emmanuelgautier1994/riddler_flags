require 'Nokogiri'
require 'open-uri'

class Scraper

    def initialize
    end
    
    def perform
        path = 'https://www.cia.gov/library/publications/the-world-factbook'
        page = '/docs/flagsoftheworld.html'
        list = Nokogiri::HTML(open path + page).css('li.flag')
        list.each do |item|
            name = item.children.css('.flag-description span')[0].content
            flag_src = path + item.children.css('img')[0].attributes['src'].value.gsub(/^\.+/, '')
            open flag_src do |image|
                File.open("./ref/" + name + ".gif", "wb") do |file|
                    file.write(image.read)
                end
            end
        end
        list.size
    end
end