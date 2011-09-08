require 'test_helper'

module Adapi
  class AdTest < Test::Unit::TestCase
    include ActiveModel::Lint::Tests

    def setup
      @model = Ad.new
    end

  end
end
