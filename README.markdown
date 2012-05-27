# Adapi #

## Description ##

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

Adapi is *still in development* and not nearly done yet! Version 1.0.0 should
have all planned functionality.

## Installation ##

`gem install adapi`

### from git repository ###

```
git clone git@github.com:lstejskal/adapi.git
cd adapi
bundle install
rake install
```

## Configuration ##

This section explains how to connect to specific AdWords account and client.
There are several options to choose from:

#### Configuration by adwords_api.yml ####

If you already have `google-adwords-api` gem configured and use just one account,
the same configuration will also work for adapi: `~/adwords_api.yml`

#### Single account set directly in code ####

```ruby
Adapi::Config.load_settings(:in_hash => {
  :sandbox => {   
      :authentication => {
        :method               => "ClientLogin"
        :email                => "sandbox_email@gmail.com",
        :password             => "sandbox_password",
        :developer_token      => "sandbox_token",
        :client_customer_id   => "555-666-7777",
        :user_agent           => "Adwords API Test"
      },
      :service => {
        :environment          => "SANDBOX"
      }
  }
})

Adapi::Config.set(:sandbox)
```

#### Multiple accounts set directly in code ####

You can set many AdWords accounts to connect to and switch between while running
the application. You can even update single values of the settings on-the-fly.

```ruby 
Adapi::Config.load_settings(:in_hash => {
  :coca_cola => {
    :authentication => {
      :method => 'ClientLogin',
      :email => 'coca_cola_email@gmail.com',
      :password => 'coca_cola_password',
      :developer_token => 'coca_cola_developer_token',
      :user_agent => 'Coca-Cola Adwords API Test'
    },
    :service => {
      :environment => 'SANDBOX'
    }
  },
 :pepsi => {
    :authentication => {
      :method => 'ClientLogin',
      :email => 'pepsi_email@gmail.com',
      :password => 'pepsi_password',
      :developer_token => 'pepsi_developer_token',
      :user_agent => 'Pepsi Adwords API Test'
    },
    :service => {
      :environment => 'SANDBOX'
    }
  }
})

# set to pepsi and specific client       
Adapi::Config.set(:pepsi, :client_customer_id => '555-666-7777')

# do some stuff here...

# set to coca-cola and another client       
Adapi::Config.set(:coca_cola, :client_customer_id => '777-666-5555')

# do some stuff here...
```

#### Configuration by `adapi.yml` ####

Stored in `~/adapi.yml`. Supports multiple accounts, which are identifed by
aliases. Example:

```
:default:
  :authentication:
    :method: ClientLogin
    :email: default_email@gmail.com
    :password: default_password
    :developer_token: default_token
    :client_customer_id: 777-666-5555
    :user_agent: My Adwords API Client
  :service:
    :environment: PRODUCTION

:sandbox:
  :authentication:
    :method: ClientLogin
    :email: sandbox_email@gmail.com
    :password: sandbox_password
    :developer_token: sandbox_token
    :client_customer_id: 555-666-7777
    :user_agent: Adwords API Test
  :service:
    :environment: SANDBOX
```

To tell adapi which account to use:

```ruby
Adapi::Config.set(:sandbox)
```

`:default` account is, as name implies, used by default. If you don't have
`:default` account available, you have to manually set account alias to
`Adapi::Config`.

### Authentication workflow ###

* try to load configuration from `~/adapi.yml`
* if `~/adapi.yml`doesn't exist, try to load configuration from
  `~/adwords_api.yml` (used by adwords-api gem)
* if there are no configuration files available, set configuration directly to
  `Adapi::Config` (overrides previous settings)

## API Version Support ##

Adapi does not support several AdWords API versions at the same time, only the
latest version: *v201109_1* at the moment.

However, support for the older versions is still available in earlier versions
of adapi (adapi 0.0.7 for *v201109*). Latest revision for specific AdWords API
version is marked by a tag.

## Unsupported AdWords services ##

Following AdWords services are not supported by adapi at the moment. However,
they will be implemented (this also serves as TODO list):

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

## Examples ##

Examples are available in [examples directory](./master/examples/). For now, they
are mostly just uninspired rewrites of examples from `google-adwords-api` gem,
but that's going to change when proper UI to AdWords models will be implemented.

### Getting started ###

Here are some examples to get you started with adapi. (All this is also
available in [examples directory](./master/examples/).)

#### Create complete campaign ###

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

#### Create campaign step by step ###

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

#### Create campaign criteria ###

Campaign criteria (formerly targets) have been rewritten from the scratch for
*v201109*. The goal is to provide a simple DSL for criteria so user doesn't have
to deal with somewhat convoluted AdWords API syntax made for machines, not
humans. So far, this has been done only for *language* and *location* criterion.
You can use any other criteria, you just have to enter them in AdWords format.

##### Language #####

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

##### Location #####

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

##### Criterion in AdWords format #####

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

## Logging ##

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

## Author ##

2011-2012 Lukas Stejskal
