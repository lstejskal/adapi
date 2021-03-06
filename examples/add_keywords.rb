# encoding: utf-8

require 'adapi'

# create ad group
require_relative 'add_bare_ad_group'

$keywords = Adapi::Keyword.new(
  :ad_group_id => $ad_group[:id],
  :keywords => [ 'dem codez', '"top coder"', '[-code]' ]
)

$keywords.create

if $keywords.errors.any?

  puts "\nERRORS:"
  pp $keywords.errors.messages

else

  puts "\nKEYWORDS CREATED\n"

  # get array of keywords from Keyword instance
  $google_keywords = Adapi::Keyword.find(:all, :ad_group_id => $ad_group[:id]).keywords

  $params_keywords = Adapi::Keyword.parameterized($google_keywords)

  $short_keywords = Adapi::Keyword.shortened($google_keywords)

  puts "DETAILED:"
  pp $params_keywords

  puts "\nSHORT:"
  pp $short_keywords

end
