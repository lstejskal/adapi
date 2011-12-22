# encoding: utf-8

require 'adapi'

# create ad group
require File.join(File.dirname(__FILE__), 'add_bare_ad_group')

$keywords = Adapi::Keyword.new(
  :ad_group_id => $ad_group[:id],
  :keywords => [ 'dem codez', '"top coder"', '[-code]' ]
)

$r = $keywords.create

# get array of keywords from Keyword instance
$google_keywords = Adapi::Keyword.find(:all, :ad_group_id => $ad_group[:id]).keywords

$params_keywords = Adapi::Keyword.parameterized($google_keywords)

$short_keywords = Adapi::Keyword.shortened($google_keywords)

p "PARAMS:"
pp $params_keywords

p "\nSHORT:"
pp $short_keywords
