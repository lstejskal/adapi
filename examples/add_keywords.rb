
require 'adapi'

# create ad group
require File.join(File.dirname(__FILE__), 'add_bare_ad_group')

$keywords = Adapi::Keyword.new(
  :ad_group_id => $ad_group[:id],
  :keywords => [ 'dem codez', '"top coder"', '[-code]' ]
)

$r = $keywords.create

p $keywords