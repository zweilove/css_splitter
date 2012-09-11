require 'test_helper'

module CssSplitter
  class ApplicationHelperTest < ActionView::TestCase
    test "should work" do
      assert_equal "<link href=\"/stylesheets/too_big_stylesheet.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />\n<link href=\"/stylesheets/too_big_stylesheet_part2.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />", split_stylesheet_link_tag("too_big_stylesheet")
    end
  end
end
