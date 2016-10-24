require 'test_helper'

class CssSplitterTest < ActiveSupport::TestCase

  setup :clear_assets_cache

  test "truth" do
    assert_kind_of Module, CssSplitter
  end

  test "asset pipeline stylesheet splitting" do
    part1 = "#test{background-color:red}"   * CssSplitter::Splitter::MAX_SELECTORS_DEFAULT
    part2 = "#test{background-color:green}" * CssSplitter::Splitter::MAX_SELECTORS_DEFAULT
    part3 = "#test{background-color:blue}"

    assert_equal "#{part1}#{part2}#{part3}",  assets["erb_stylesheet"].to_s.gsub(/\s/, '')
    assert_equal "#{part2}",                  assets["erb_stylesheet_split2"].to_s.gsub(/\s/, '')
    assert_equal "#{part3}",                  assets["erb_stylesheet_split3"].to_s.gsub(/\s/, '')
  end

  test "asset pipeline stylesheet splitting on stylesheet combined using requires" do
    red   = "#test{background-color:red}"   * 100
    green = "#test{background-color:green}" * CssSplitter::Splitter::MAX_SELECTORS_DEFAULT
    blue  = "#test{background-color:blue}"
    assert_equal "#{red}#{green}#{blue}",                           assets["combined"].to_s.gsub(/\s/, '')
    assert_equal "#{"#test{background-color:green}" * 100}#{blue}", assets["combined_split2"].to_s.gsub(/\s/, '')
  end

  private

  def clear_assets_cache
    assets_cache = Rails.root.join("tmp/cache/assets")
    assets_cache.rmtree if assets_cache.exist?
  end

  def assets
    Rails.application.assets
  end

end
