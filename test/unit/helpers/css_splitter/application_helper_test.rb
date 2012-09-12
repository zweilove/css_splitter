require 'test_helper'

module CssSplitter
  class ApplicationHelperTest < ActionView::TestCase

    test "should work w/out options" do
      output = split_stylesheet_link_tag("too_big_stylesheet")
      assert_equal "<link href=\"/stylesheets/too_big_stylesheet.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />\n<!--[if lte IE 9]>\n<link href=\"/stylesheets/too_big_stylesheet_split2.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />\n<![endif]-->", output
    end

    test "should work with options and multiple stylesheets" do
      output = split_stylesheet_link_tag("too_big_stylesheet", "foo", media: "print")
      assert_equal "<link href=\"/stylesheets/too_big_stylesheet.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\" />\n<link href=\"/stylesheets/foo.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\" />\n<!--[if lte IE 9]>\n<link href=\"/stylesheets/too_big_stylesheet_split2.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\" />\n<link href=\"/stylesheets/foo_split2.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\" />\n<![endif]-->", output
    end

  end
end
