# encoding: utf-8

# PS: gotta run without :client_customer_id parameter set in configuration
# alternatively, calling self.adwords.use_mcc should also work

require 'adapi'

$account = Adapi::Account.new(
  :name => 'Test Account',
  :currency_code => 'CZK',
  :date_time_zone => 'Europe/Prague'
)

$response = $account.create

unless $account.errors.empty?

  puts "ERROR WHEN CREATING ACCOUNT \"#{$account[:name]}\":"
  pp $account.errors.full_messages

else

  puts "CREATED ACCOUNT \"#{$account[:name]}\" WITH CUSTOMER ID \"#{$account[:customer_id]}\":"

  # FIXME
  # $account = Adapi::Account.find(:first, :customer_id => $account[:id])

  puts "\nACCOUNT DATA:"
  pp $account.attributes

end
