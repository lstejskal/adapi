# encoding: utf-8

require 'adapi'

# create ad group
require File.join(File.dirname(__FILE__), 'add_bare_ad_group')

$keywords = Adapi::Keyword.new(
  :ad_group_id => $ad_group[:id],
  :keywords => [ 'dem codez', '-hacker' ]
)

$r = $keywords.create

# get array of keywords for ad_group
$google_keywords = Adapi::Keyword.find(:all, :ad_group_id => $ad_group[:id]).keywords

p "BEFORE DELETE: #{$google_keywords.size} keywords"

if Adapi::Keyword.new(:ad_group_id => $ad_group[:id]).delete($google_keywords.first[:text][:criterion][:id])
  p "SUCCESS: first keyword deleted."
else
  p "ERROR: keyword could not be deleted."
end

$google_keywords = Adapi::Keyword.find(:all, :ad_group_id => $ad_group[:id]).keywords
p "AFTER DELETE: #{$google_keywords.size} keywords"
