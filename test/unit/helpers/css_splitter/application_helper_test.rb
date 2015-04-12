require 'test_helper'

module CssSplitter
  class ApplicationHelperTest < ActionView::TestCase

    test "should work w/out options" do
      output = split_stylesheet_link_tag("too_big_stylesheet")
      assert_equal "<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet.css\" />\n<!--[if lte IE 9]>\n<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet_split2.css\" />\n<![endif]-->", output
    end

    test "should work with options and multiple stylesheets" do
      output = split_stylesheet_link_tag("too_big_stylesheet", "foo", media: "print")
      assert_equal "<link rel=\"stylesheet\" media=\"print\" href=\"/stylesheets/too_big_stylesheet.css\" />\n<!--[if lte IE 9]>\n<link rel=\"stylesheet\" media=\"print\" href=\"/stylesheets/too_big_stylesheet_split2.css\" />\n<![endif]-->\n<link rel=\"stylesheet\" media=\"print\" href=\"/stylesheets/foo.css\" />\n<!--[if lte IE 9]>\n<link rel=\"stylesheet\" media=\"print\" href=\"/stylesheets/foo_split2.css\" />\n<![endif]-->", output
    end

    test "should work with split_count option" do
      output = split_stylesheet_link_tag("too_big_stylesheet", split_count: 3)
      assert_equal "<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet.css\" />\n<!--[if lte IE 9]>\n<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet_split2.css\" />\n<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet_split3.css\" />\n<![endif]-->", output
    end

    class RailsEnvDefault < ActionView::TestCase
      setup do
        Rails.env = 'development'
      end

      teardown do
        Rails.env = 'test'
      end

      test "should default to false on splits" do
        output = split_stylesheet_link_tag("too_big_stylesheet")
        assert_equal "<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet.css\" />\n<!--[if lte IE 9]>\n<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet_split2.css\" debug=\"false\" />\n<![endif]-->", output
      end

      test "should respect the debug=true option" do
        output = split_stylesheet_link_tag("too_big_stylesheet", debug: true)
        assert_equal "<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet.css\" debug=\"true\" />\n<!--[if lte IE 9]>\n<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet_split2.css\" debug=\"true\" />\n<![endif]-->", output
      end
      test "should respect the debug=false option" do
        output = split_stylesheet_link_tag("too_big_stylesheet", debug: false)
        assert_equal "<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet.css\" debug=\"false\" />\n<!--[if lte IE 9]>\n<link rel=\"stylesheet\" media=\"screen\" href=\"/stylesheets/too_big_stylesheet_split2.css\" debug=\"false\" />\n<![endif]-->", output
      end
    end
  end
end
