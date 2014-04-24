require 'test_helper'

class CssSplitterTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, CssSplitter
  end

  test "config" do
    assert_kind_of CssSplitter::Engine::Configuration, CssSplitter.config
  end

  test "config_set_options" do
    CssSplitter.config.max_selectors = 10

    assert_equal 10, CssSplitter.config.max_selectors
  end

  test "config_default_options" do
    assert_equal 4095, CssSplitter.config.max_selectors
    assert_equal 2, CssSplitter.config.number_of_splits
  end
end
