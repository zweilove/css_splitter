require 'test_helper'

module CssSplitter
  class ApplicationHelperTest < ActionView::TestCase

    test "should work w/out options" do
      output = split_stylesheet_link_tag("too_big_stylesheet")
      assert_equal "<link href=\"/stylesheets/too_big_stylesheet.css\" media=\"screen\" rel=\"stylesheet\" />\n<!--[if lte IE 9]>\n<link href=\"/stylesheets/too_big_stylesheet_split2.css\" media=\"screen\" rel=\"stylesheet\" />\n<![endif]-->", output
    end

    test "should work with options and multiple stylesheets" do
      output = split_stylesheet_link_tag("too_big_stylesheet", "foo", media: "print")
      assert_equal "<link href=\"/stylesheets/too_big_stylesheet.css\" media=\"print\" rel=\"stylesheet\" />\n<!--[if lte IE 9]>\n<link href=\"/stylesheets/too_big_stylesheet_split2.css\" media=\"print\" rel=\"stylesheet\" />\n<![endif]-->\n<link href=\"/stylesheets/foo.css\" media=\"print\" rel=\"stylesheet\" />\n<!--[if lte IE 9]>\n<link href=\"/stylesheets/foo_split2.css\" media=\"print\" rel=\"stylesheet\" />\n<![endif]-->", output
    end

    test "should work with split_count option" do
      output = split_stylesheet_link_tag("too_big_stylesheet", split_count: 3)
      assert_equal "<link href=\"/stylesheets/too_big_stylesheet.css\" media=\"screen\" rel=\"stylesheet\" />\n<!--[if lte IE 9]>\n<link href=\"/stylesheets/too_big_stylesheet_split2.css\" media=\"screen\" rel=\"stylesheet\" />\n<link href=\"/stylesheets/too_big_stylesheet_split3.css\" media=\"screen\" rel=\"stylesheet\" />\n<![endif]-->", output
    end

    test "should default to false on splits" do
      Rails.env = 'development'
      output = split_stylesheet_link_tag("too_big_stylesheet")
      Rails.env = 'test'
      assert_equal "<link href=\"/stylesheets/too_big_stylesheet.css\" media=\"screen\" rel=\"stylesheet\" />\n<!--[if lte IE 9]>\n<link debug=\"false\" href=\"/stylesheets/too_big_stylesheet_split2.css\" media=\"screen\" rel=\"stylesheet\" />\n<![endif]-->", output
    end

    test "should respect the debug=true option" do
      Rails.env = 'development'
      output = split_stylesheet_link_tag("too_big_stylesheet", debug: true)
      Rails.env = 'test'
      assert_equal "<link debug=\"true\" href=\"/stylesheets/too_big_stylesheet.css\" media=\"screen\" rel=\"stylesheet\" />\n<!--[if lte IE 9]>\n<link debug=\"true\" href=\"/stylesheets/too_big_stylesheet_split2.css\" media=\"screen\" rel=\"stylesheet\" />\n<![endif]-->", output
    end
    test "should respect the debug=false option" do
      Rails.env = 'development'
      output = split_stylesheet_link_tag("too_big_stylesheet", debug: false)
      Rails.env = 'test'
      assert_equal "<link debug=\"false\" href=\"/stylesheets/too_big_stylesheet.css\" media=\"screen\" rel=\"stylesheet\" />\n<!--[if lte IE 9]>\n<link debug=\"false\" href=\"/stylesheets/too_big_stylesheet_split2.css\" media=\"screen\" rel=\"stylesheet\" />\n<![endif]-->", output
    end
  end
end
