
Factory.define :text_ad, :class => Adapi::Ad::TextAd do |f|
  f.sequence(:ad_group_id)    { |n| n }
  f.headline                  'Code like Neo'
  f.description1              'Need mad coding skills?'
  f.description2              'Check out my new blog!'
  f.url                       'http://www.demcodez.com'
  f.display_url               'http://www.demcodez.com'  
end