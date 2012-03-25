# encoding: utf-8

# I can haz hack?! This hotfixes OAuth
# FIXME remove when new version of ads-common is released

# And not only this is monkeypatch, but we're changing constant as well...
# Look ma, no warnings!
AdsCommon::Auth::OAuthHandler::IGNORED_FIELDS.send('<<', :oauth_token_secret)
AdsCommon::Auth::OAuthHandler::IGNORED_FIELDS.send('<<', :oauth_token)
