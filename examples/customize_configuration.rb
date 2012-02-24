# encoding: utf-8

require 'adapi'

# this example shows how to load custom settings

Adapi::Config.load_settings(
  :dir => File.expand_path(File.dirname(__FILE__)),
  :filename => 'custom_settings.yml'
)

# :default account is set automatically
p "Default settings:"
p Adapi::Config.read[:authentication][:email]

Adapi::Config.set(:sandbox)
p "Set :sandbox account:"
p Adapi::Config.read[:authentication][:email]
