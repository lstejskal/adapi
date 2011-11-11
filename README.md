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

```
gem install adapi
```

### from git repository ###

```
git clone git@github.com:lstejskal/adapi.git
cd adapi
bundle install
rake install
```

## Configuration ##

This section explains how to connect to specific AdWords account and client.

You can set many AdWords accounts to connect to and switch between while running
the application. You can even update single values of the settings on-the-fly.

```ruby 
# load the settings
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

### Authentication workflow ###

* load configuration from `~/adapi.yml`
* load configuration from `~/adwords_api.yml` (default configuration for AdWords gems
  from Google)
* set configuration directly to `Adapi::Config` (overrides previous settings)

### Configuration by `adapi.yml` ###

Stored in `~/adapi.yml`. Supports multiple accounts, which are identifed by
aliases. Example:

```
:default:
  :authentication:
    :method: ClientLogin
    :email: default_email@gmail.com
    :password: default_password
    :developer_token: default_token
    :client_email: default_client_email@gmail.com
    :user_agent: My Adwords API Client
  :service:
    :environment: PRODUCTION

:sandbox:
  :authentication:
    :method: ClientLogin
    :email: sandbox_email@gmail.com
    :password: sandbox_password
    :developer_token: sandbox_token
    :client_email: sandbox_client_email@gmail.com
    :user_agent: Adwords API Test
  :service:
    :environment: SANDBOX
```

You tell adapi which account to use by setting an alias:

```ruby
Adapi::Config.set(:sandbox)
```

`:default` account is, as name implies, used by default. You must either set an
alias to `Adapi::Config` or have account with `:default` alias available.

### Configuration by adwords_api.yml ###

If you already have `google-adwords-api` gem configured and use just one account,
the same configuration will also work for adapi: `~/adwords_api.yml`

### Configuration directly in code ###

Before logging into the Adwords API, you can set global settings through
`Adapi::Config`:

```ruby
# load the settings
Adapi::Config.load_settings(:in_hash => {
  :sandbox => {   
      :authentication => {
        :method           => "ClientLogin"
        :email            => "sandbox_email@gmail.com",
        :password         => "sandbox_password",
        :developer_token  => "sandbox_token",
        :client_email     => "sandbox_client_email@gmail.com",
        :user_agent       => "Adwords API Test"
      },
      :service => {
        :environment      => "SANDBOX"
      }
  }
})

Adapi::Config.set(:sandbox)
```

## API Version Support ##

Adapi supports only the latest version of Google AdWords API: `v201109`. Older
versions will not be supported (well, maybe `v201101`). `v201109` and newer
versions will still be supported when new versions are released.

## Examples ##

Example are available in [examples directory](./master/examples/). For now, they
are mostly just uninspired rewrites of examples from `google-adwords-api` gem,
but that's going to change when proper UI to AdWords models will be implemented.

## Author ##

2011 Lukas Stejskal
