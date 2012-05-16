# encoding: utf-8

FactoryGirl.define do

  factory :text_ad, :class => Adapi::Ad::TextAd do
    sequence(:ad_group_id)    { |n| n }
    headline                  'Code like Neo'
    description1              'Need mad coding skills?'
    description2              'Check out my new blog!'
    url                       'http://www.demcodez.com'
    display_url               'http://www.demcodez.com'
  end

end