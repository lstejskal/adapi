
require 'adapi'

# create ad group
require File.join(File.dirname(__FILE__), 'add_bare_ad_group')

$keywords = Adapi::Keyword.new(
  :ad_group_id => $ad_group[:id],
  :keywords => [
    { :text => 'dem codez', :match_type => 'BROAD', :negative => false },
    { :text => 'top coder', :match_type => 'PHRASE', :negative => false },
    { :text => 'code', :match_type => 'EXACT', :negative => true }
  ]
)

$r = $keywords.create

p $keywords