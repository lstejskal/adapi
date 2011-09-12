require 'test_helper'

module Adapi
  class TextAdTest < Test::Unit::TestCase
    include ActiveModel::Lint::Tests

    def setup
      @model = Ad::TextAd.new
    end

    context "valid new TextAd instance" do
      setup do
        @text_ad = Factory.build(:text_ad)
      end

      should "be valid" do
        assert @text_ad.valid?
      end

      context " / data method" do
        should "return TextAd params in hash" do
          assert @text_ad.data.is_a?(Hash)
          assert_equal @text_ad.headline, @text_ad.data[:headline]
        end
      end

    end

  end
end
