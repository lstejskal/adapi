require 'test_helper'

module Adapi
  class TextAdTest < Test::Unit::TestCase
    include ActiveModel::Lint::Tests

    def setup
      @model = Ad::TextAd.new
    end

  end
end
