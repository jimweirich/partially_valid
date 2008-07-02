require 'rubygems'
require 'test/unit'
require 'partially_valid'
require 'flexmock/test_unit'

class FauxErrors
  def initialize
    clear
  end
  def add(attr, msg)
    @errors[attr.to_s] = msg
  end
  def on(attr)
    @errors[attr.to_s]
  end
  def empty?
    @errors.empty?
  end
  def clear
    @errors = {}
  end
  def each(&block)
    @errors.each(&block)
  end
end

class FauxModel < ActiveRecord::Base
  attr_reader :errors

  def valid?
    @errors = FauxErrors.new
    @errors.add("x", "bad value")
    @errors.empty?
  end
end

class TestPartiallyValid < Test::Unit::TestCase
  def test_faux_model_has_errors
    model = FauxModel.new
    assert ! model.valid?, "Faux Model should have errors"
    assert_equal "bad value", model.errors.on(:x)
  end

  def test_model_with_no_pv_attributes_is_partially_valid
    model = FauxModel.new
    assert model.partially_valid?, "should be partially valid"
    assert model.errors.empty?
  end

  def test_model_with_pv_attributes_is_not_partially_valid
    model = FauxModel.new
    model.should_be_partially_valid_on(:x)
    assert ! model.partially_valid?, "should not be partially valid"
    assert ! model.errors.empty?
    assert_equal "bad value", model.errors.on(:x)
  end

  def test_model_can_clear_pv_attributes
    model = FauxModel.new
    model.should_be_partially_valid_on(:x)
    model.partially_valid_clear
    assert model.partially_valid?, "should be partially valid"
  end
end

