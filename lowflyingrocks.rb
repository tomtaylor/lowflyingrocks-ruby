#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require 'hpricot'
require 'time'
require 'bigdecimal/util'

current_path = File.dirname(__FILE__)

html_path = File.join(current_path, 'lowflyingrocks.html')

doc = Hpricot(open(html_path))

table = doc.search("html > body > table > tr:nth(8) > td:nth(1) > center > table > tr:nth(1) > td > table > tr:nth(1) > td > table")

# all_rows = first_row()
# table.shift

asteroids = []

rows = table.search("//tr")
rows.shift

rows.each do |row|
  data = row.search("//td//font")
  asteroid = {}
  asteroid[:name] = data[0].inner_html.gsub(/&nbsp;/, ' ').gsub(/\(|\)/, '').strip
  asteroid[:datetime] = Time.parse(data[1].inner_html.gsub(/&nbsp;/, ' ').split('&plusmn;').first.strip + " UTC") # force UTC
  asteroid[:au_norm] = data[2].inner_html.split('/')[1].to_s
  # asteroid[:au_min] = data[3].inner_html.split('/')[1].to_f
  asteroid[:speed] = data[4].inner_html.to_f.round
  asteroid[:h] = data[7].inner_html.to_f
  asteroids << asteroid
end

def get_distance(distance)
  distance = BigDecimal(distance) * 149598000
  distance = distance.round(3-distance.exponent).to_i
  distance.en.numwords
end

def get_size(h)
  p = 0.05
  high_d = ((1329/Math.sqrt(p))*10 ** (-0.2*h)*1000).to_d
  
  p = 0.25
  low_d = ((1329/Math.sqrt(p))*10 ** (-0.2*h)*1000).to_d
  
  low_d = low_d.round(2-low_d.exponent).to_i
  high_d = high_d.round(2-high_d.exponent).to_i
  "#{low_d.to_s}m-#{high_d.to_s}m"
end

asteroids.each do |asteroid|
  if asteroid[:datetime] <= Time.now and asteroid[:datetime] > Time.now - 300
    gem 'twitter4r'
    require 'twitter'
    require 'bigdecimal'
    require 'linguistics'
    Linguistics::use( :en )
    distance = get_distance(asteroid[:au_norm])
    message = "#{asteroid[:name]}, ~#{get_size(asteroid[:h])} in diameter, just passed the Earth at #{asteroid[:speed]}km/s, missing by ~#{distance} km."
    #puts message
    client = Twitter::Client.from_config(File.join(current_path, 'oauth.yml'), 'lowflyingrocks')
    client.status(:post, message)
  end
end
