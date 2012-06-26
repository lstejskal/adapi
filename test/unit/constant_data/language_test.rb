# encoding: utf-8

require 'test_helper'

module Adapi
  class LanguageTest < Test::Unit::TestCase

    context "Language.find" do

      should "return instance of Language class" do
        assert_instance_of ConstantData::Language, ConstantData::Language.find('cs')
      end

      should "find language id by language code" do
        assert_equal 1021, ConstantData::Language.find('cs').id
      end

      should "return nil for unknown language code" do
        assert_equal nil, ConstantData::Language.find('unknown').id
      end

      should "return language code for language id" do
        assert_equal :cs, ConstantData::Language.find(1021).code
      end

      should "return nil for unknown language id" do
        assert_equal nil, ConstantData::Language.find(12345).code
      end

    end

  end
end

