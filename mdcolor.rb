require 'bundler'
Bundler.require

require 'open-uri'
require 'fileutils'

require 'active_support'
require 'active_support/core_ext'

URL = 'https://www.google.com/design/spec/style/color.html'
HTML_FILE = 'tmp/color.html'

FileUtils.mkdir_p('tmp')

if File.exists?(HTML_FILE)
  html = File.read(HTML_FILE)
else
  html = open(URL).read
  File.write(HTML_FILE, html)
end

groups = {}
main_colors = {}

doc = Nokogiri::HTML(html)
doc.css('.color-group').each do |group|
  main_color = group.css('.main-color')
  next if main_color.blank?

  name = main_color.at('.name').text

  main_colors[name] = main_color.at('.hex').text[1..-1]

  colors = {}

  group.css('.color').each do |color|
    shade = color.at('.shade').text
    hex = color.at('.hex').text
    colors[shade] = hex[1..-1]
  end

  groups[name] = colors
end

# Helpers

def camelize_name(name)
  name.parameterize.underscore.camelize(:lower)
end

def hex_to_uicolor(hex)
  r, g, b = hex.scan(/.{2}/).map { |h| h.to_i(16) }
  "UIColor(red: #{r}.0 / 255.0, green: #{g}.0 / 255.0, blue: #{b}.0 / 255.0, alpha: 1.0)"
end

# Render

FileUtils.mkdir_p('build')

Dir::glob('templates/*.erb').each do |template|
  erb = ERB.new(File.read(template), nil, '-')
  result = erb.result
  filename = File.basename(template, '.erb')
  File.write("build/#{filename}", result)
end

