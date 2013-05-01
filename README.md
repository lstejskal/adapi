# Adapi [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/lstejskal/adapi)

**This gem is no longer under active development.**

I have decided to stop developing this gem. To give you some time to adapt, I will maintain version 0.2 until the sunset of *v201209* in June 2013. I will not update adapi to *v201302*, so in June 2013 this gem will become effectively obsolete.

Reasons:

* Lately, AdWords API has been changing rapidly. This is a problem for me because I'm trying to create high-level abstraction for easy work with 
AdWords API and that's frustrating to do when the API keeps changing under my hands.

* This project originally started as an abstraction of my work project. Since then, I've changed jobs, so I don't work professionaly with AdWords API anymore and I want to dedicate my free time to other projects.

* This project stopped being fun. It was, at the start. But since then AdWords API has begun changing a lot and it's not fun keeping track with new API versions. Also, [SOAP](https://twitter.com/adron/status/296787545746964480). 

If you're interested in maintaining this gem, please contact me. 

## Description

Adapi (ADwords API) is a Ruby library for easy and painless work with Google
Adwords API. Its users shouldn't bother with SOAP and tangle of XML- and
API-specific objects, inputs and outputs are plain Ruby arrays and hashes. 

Adapi is built on `google-adwords-api` gem. Arrays and hashes instead of objects
come from there, but adapi takes it several steps further:

* AdWords services are represented by ActiveModel-compatible models with
  relations. Among other things it's possible to create whole campaign in
  single method call: `Adapi::Campaign.create(campaign_data)`.

* Various convenience methods are added to the models, for example:
  `campaign.pause!` (pauses campaign).

* Adapi enables you to easily work with multiple AdWords accounts at the same time.

Adapi supports the latest version of AdWords API: *v201209*. 

## Installation

`gem install adapi`

### from git repository

```
git clone git@github.com:lstejskal/adapi.git
cd adapi
bundle install
rake install
```

## Configuration

This section explains how to connect to specific AdWords account and client. The configuration
structure is quite similar to the configuration of `google-adwords-api` gem.

There are several options to choose from:

#### Single account set directly in code

```ruby
Adapi::Config.load_settings( in_hash: {
  production: {
    authentication: {
      method:                 "OAuth2",
      oauth2_client_id:       "abc",
      oauth2_client_secret:   "def",
      oauth2_token: {
        access_token:         "123",
        refresh_token:        "456",
        issued_at:            "2013-03-03 13:33:39.734203841 +01:00",
        expires_in:           3600,
        id_token:             nil
      },
      developer_token:        "789",
      user_agent:             "My Adwords API Client",
      client_customer_id:     "555-666-7777"
    },
    service: {
      environment: "PRODUCTION"
    }
  }
})

Adapi::Config.set(:production)
```

#### Multiple accounts set directly in code

You can set many AdWords accounts to connect to and switch between while running
the application. You can even update single values of the settings on-the-fly.

```ruby 
Adapi::Config.load_settings( in_hash: {
  coca_cola:  config_hash_for_coca_cola,
  pepsi:      config_hash_for_pepsi
})

# set to pepsi and specific client       
Adapi::Config.set(:pepsi, :client_customer_id => '555-666-7777')

# do some stuff here...

# set to coca-cola and another client       
Adapi::Config.set(:coca_cola, :client_customer_id => '777-666-5555')

# do some stuff here...
```

#### Configuration by `adapi.yml`

Stored in `~/adapi.yml`. Supports multiple accounts, which are identifed by
aliases. Example:

```

:default:
  :authentication:
    :method: OAuth2
    :oauth2_client_id: "abc"
    :oauth2_client_secret: "def"
    :oauth2_token:
        :access_token: "123"
        :refresh_token: "456"
        :issued_at: 2013-03-03 13:33:39.734203841 +01:00
        :expires_in: 3600
        :id_token:
    :developer_token: "789"
    :user_agent: My Adwords API Client
    :client_customer_id: 555-666-7777
  :service:
    :environment: PRODUCTION
  :library:
    :log_level: WARN
    :log_path: /tmp/adapi.log
    :log_pretty_format: true

```

To tell adapi which account to use:

```ruby
Adapi::Config.set(:production)
```

`:default` account is, as name implies, used by default. If you don't have
`:default` account available, you have to manually set account alias to
`Adapi::Config`.

### How to get OAuth2 token

* get `oauth2_client_id` and `oauth2_client_secret`: [https://code.google.com/p/google-api-ads-ruby/wiki/OAuth2][https://code.google.com/p/google-api-ads-ruby/wiki/OAuth2]

* put them into adapi configuration file

* run following script:

```ruby
require 'adapi'
require 'yaml'

adapi_object = Adapi::Location.new() # load any adapi object
adwords_api = adapi_object.adwords # get adwords object

# got to url and paste verification code to the script
oauth2_token = adwords.authorize() do |auth_url|
  puts "Go to URL:\n\t%s" % auth_url
  print 'log in and type the verification code: '
  gets.chomp
end

puts oauth2_token.to_yaml 
```

* put `oauth2_token` hash adapi configuration file

Code taken from this google-adwords-api example: [https://code.google.com/p/google-api-ads-ruby/source/browse/adwords_api/examples/v201209/misc/use_oauth2.rb][https://code.google.com/p/google-api-ads-ruby/source/browse/adwords_api/examples/v201209/misc/use_oauth2.rb]

## API Version Support

Adapi supports the latest version of AdWords API: *v201209*. 

For support of earlier versions of AdWords API, downgrade to earlier 
versions of adapi: 0.1.5 for *v201206*, 0.0.9 for *v201109_1*, 0.07 for *v201109*. 
(You shoudn't need it though, older versions of AdWords API are 
eventually shut down.) Latest revision for specific AdWords API version 
is also marked by a tag.

Adapi tries to not to bother users with AdWords API low-level specifics as much 
as possible, if you're upgrading to newer version of AdWords API, please be cautious, 
check the [release notes](https://developers.google.com/adwords/api/docs/reference/)
and update your code accordingly. Adapi won't accept obsolete attributes etc. 

## Unsupported AdWords services

Following AdWords services are not supported by adapi at the moment, and exist
only on my TODO list:

* Campaign Data Management
  * ConversionTrackerService
  * UserListService

* Optimization
  * BulkOpportunityService
  * ReportDefinitionService
  * TargetingIdeaService
  * TrafficEstimatorService

* Account Management
  * CustomerSyncService

* Utility
  * MutateJobService
  * BulkMutateJobService

## Examples

Examples are available in [examples directory](./master/examples/). For now, they
are mostly just uninspired rewrites of examples from `google-adwords-api` gem,
but that's going to change when proper UI to AdWords models will be implemented.

### Getting started

Here are some examples to get you started with adapi. (All this is also
available in [examples directory](./master/examples/).)

#### Create complete campaign

Creates a campaign with ad_groups and ad_texts from hash - by single method call.

```ruby
campaign = Adapi::Campaign.create(
  :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  :bidding_strategy => {
    :xsi_type => 'BudgetOptimizer',
    :bid_ceiling => 100
  },
  :budget => {
    :amount => 50,
    :delivery_method => 'STANDARD'
  },

  :criteria => {
    :language => [ :en, :cs ],
    :location => {
      # PS: province and country codes are now obsolete in AdWords API,
      # but they still work in adapi
      :name => { :city => 'Prague', :region => 'CZ-PR', :country => 'CZ' }
    }
  },

  :ad_groups => [
    {
      :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
      :status => 'ENABLED',

      :keywords => [ 'dem codez', '"top coder"', "[-code]" ],

      :ads => [
        {
          :headline => "Code like Neo",
          :description1 => 'Need mad coding skills?',
          :description2 => 'Check out my new blog!',
          :url => 'http://www.demcodez.com',
          :display_url => 'http://www.demcodez.com'
        }
      ]
    }
  ]
)
```

#### Create campaign step by step

Creates a campaign with ad_groups and ad_texts step by step.

```ruby
campaign = Adapi::Campaign.create(
  :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  :bidding_strategy => { :xsi_type => 'BudgetOptimizer', :bid_ceiling => 100 },
  :budget => { :amount => 50, :delivery_method => 'STANDARD' }
)

Adapi::CampaignCriterion.create(
  :campaign_id => campaign.id,
  :criteria => { 
    :language => %w{ en cs },
    :location => {
      :name => { :city => 'Prague', :region => 'CZ-PR', :country => 'CZ' }
    }
  }
)

ad_group = Adapi::AdGroup.create(
  :campaign_id => campaign.id,
  :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'ENABLED'
)

Adapi::Keyword.create(
  :ad_group_id => ad_group.id,
  :keywords => [ 'dem codez', '"top coder"', '[-code]' ]
)

Adapi::Ad::TextAd.create(
  :ad_group_id => ad_group.id,
  :headline => "Code like Neo",
  :description1 => 'Need mad coding skills?',
  :description2 => 'Check out my new blog!',
  :url => 'http://www.demcodez.com',
  :display_url => 'http://www.demcodez.com'
)

# find complete campaign
new_campaign = Adapi::Campaign.find_complete(campaign.id)

# display campaign as hash
puts new_campaign.to_hash.inspect
```

#### Create campaign criteria

Campaign criteria (formerly targets) have been rewritten from the scratch for
*v201109*. The goal is to provide a simple DSL for criteria so user doesn't have
to deal with somewhat convoluted AdWords API syntax made for machines, not
humans. So far, this has been done only for *language* and *location* criterion.
You can use any other criteria, you just have to enter them in AdWords format.

##### Language

```ruby
Adapi::CampaignCriterion.create(
  :campaign_id => campaign.id,
  :criteria => { 
    :language => %w{ en cs },
  }
)
```

`:language` parameter accepts string or symbols for single language target or
array of strings/symbols for several language targets.

##### Location

```ruby
Adapi::CampaignCriterion.create(
  :campaign_id => campaign.id,
  :criteria => { 
    :location => { 
      :name => { :city => 'Prague', :region => 'CZ-PR', :country => 'CZ' }
    }    
)

```

This criterion has been heavily customized in adapi to comply with legacy
interfaces (pre-v201109). In other words, you don't have to enter locations as
ids (although you can). `:location` accepts following parameters:

* `:id` - this is standard location interface of AdWords `v201109_1`

```ruby
:location => location_id
:location => { :id => location_id }
:location => { :id => [ location_id ] }
```

* `:proximity`
  * `:geo_point`: "longitude,lattitude"
  * `:radius`: "radius_in_units radius_units"

```ruby
:location => { :proximity => { :geo_point => '50.083333,14.366667', :radius => '50 km' } }
```

* `:name` - hash with parameters specifying location name:
  * `:city`
  * `:region` (also `:province`) - as name (`"New York"`) or code (`"US-NY"`)
  * `:country` - as name (`"Czech Republic"`) or code (`"CZ"`)

```ruby
:location => { :name => { :country => 'Czech Republic' } }
:location => { :name => { :city => 'Prague' } }
:location => { :name => { :city => 'Prague', :region => 'CZ-PR', :country => 'CZ' } }
```

Unfortunately, at the moment you can't target more locations in one
CampaignCriterion request. This is going to be fixed in the next version, but
for now please use following workaround - call CampaignCriterion several times:

```ruby
Adapi::CampaignCriterion.create(
  :campaign_id => campaign.id,
  :criteria => { 
    :location => { 
      :name => { :city => 'Prague', :region => 'CZ-PR', :country => 'CZ' }
    }    
)

Adapi::CampaignCriterion.create(
  :campaign_id => campaign.id,
  :criteria => { 
    :location => {
      :name => { :city => 'Brno', :region => 'CZ-JM', :country => 'CZ' }
    }
  }
)
```

##### Criterion in AdWords format

Convenient shortcuts for other criteria besides *language* and *location* are
not yet implemented. However, you can use any other criteria, you just have to
enter them as ids.

```ruby
Adapi::CampaignCriterion.create(
  :campaign_id => campaign.id,
  :criteria => {
    :platform => [ { :id => 30001} ]
  }
)
```

## Logging

By default, communication with AdWords API is not logged. In order to log
messages of certain log level or above, set `library/log_level` in configuration
(INFO or DEBUG setting is recommended for local development).

Default log path is "~/adapi.log". You can set custom log path in:
`library/log_path`.

By default, SOAP messages are logged in ugly format - everything fits on single
line. It's fast, but quite difficult to read. To log SOAP requests and responses
in pretty format, set `library/log_pretty_format` in configuration to `true`.

Example of logger configuration:

```
  :library:
    :log_level: DEBUG
    :log_path: /home/username/log/adapi.log
    :log_pretty_format: true
```

## Author

2011-2013 Lukas Stejskal, Ataxo Interactive, a.s.

