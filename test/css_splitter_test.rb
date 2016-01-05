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

    assert_equal "#{part1}#{part2}#{part3}\n",  assets["erb_stylesheet"].to_s
    assert_equal "#{part2}\n",                  assets["erb_stylesheet_split2"].to_s
    assert_equal "#{part3}\n",                  assets["erb_stylesheet_split3"].to_s
  end

  test "asset pipeline stylesheet splitting on stylesheet combined using requires" do
    red   = "#test{background-color:red}"   * 100
    green = "#test{background-color:green}" * CssSplitter::Splitter::MAX_SELECTORS_DEFAULT
    blue  = "#test{background-color:blue}"

    assert_equal "#{red}#{green}#{blue}\n",                           assets["combined"].to_s
    assert_equal "#{"#test{background-color:green}" * 100}#{blue}\n", assets["combined_split2"].to_s
  end

  private

  def clear_assets_cache
    assets_cache = Rails.root.join("tmp/cache/assets")
    assets_cache.rmtree if assets_cache.exist?
  end

  def assets
    Sprockets::Environment.new(Rails.root).tap do |assets|
      assets.append_path Rails.root.join("app/assets/stylesheets")
      assets.css_compressor = :sass
    end
  end
end
