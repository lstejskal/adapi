
# this is a monkeypatch for integration tests
#
class Test::Unit::TestCase
  FakeWeb.allow_net_connect = true

  def setup
    # allow OAuth2 authorization for integration tests
    AdwordsApi::Api.any_instance.unstub(:authorize)
  end
end
