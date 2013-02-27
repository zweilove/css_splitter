require 'test_helper'

class CssSplitterTest < ActiveSupport::TestCase
  test "#count_selectors" do
    assert_equal 2938, CssSplitter::Splitter.count_selectors('test/unit/too_many_selectors.css')
  end

  test "#count_selectors_of_rule" do
    assert_equal 1, CssSplitter::Splitter.count_selectors_of_rule('foo { color: baz; }')
    assert_equal 2, CssSplitter::Splitter.count_selectors_of_rule('foo, bar { color: baz; }')
  end

  # --- split_string_into_rules ---

  test '#split_string_into_rules' do
    simple = "a{foo:bar;}b{baz:qux;}"
    assert_equal ["a{foo:bar;}", "b{baz:qux;}"], CssSplitter::Splitter.split_string_into_rules(simple)
  end

  test '#split_string_into_rules for single line comments' do
    multi_line = "a{foo:bar;} /* comment p{bar:foo;} */ b{baz:qux;}"
    assert_equal ["a{foo:bar;}", "  b{baz:qux;}"], CssSplitter::Splitter.split_string_into_rules(multi_line)
  end

  test '#split_string_into_rules for multiline comments' do
    multi_line = "a{foo:bar;}\n/*\nMultiline comment p{bar:foo;}\n*/\nb{baz:qux;}"
    assert_equal ["a{foo:bar;}", "\n\nb{baz:qux;}"], CssSplitter::Splitter.split_string_into_rules(multi_line)
  end

  test '#split_string_into_rules for strings with protocol independent urls' do
    simple = "a{foo:url(//assets.server.com);}b{bar:url(//assets/server.com);}"
    assert_equal ["a{foo:url(//assets.server.com);}", "b{bar:url(//assets/server.com);}"], CssSplitter::Splitter.split_string_into_rules(simple)
  end

  # --- extract_charset ---

  test '#extract_charset with no charset' do
    first_rule = ".foo { color: black; }"
    assert_equal [nil, first_rule], CssSplitter::Splitter.send(:extract_charset, first_rule)
  end

  test '#extract_charset with charset' do
    first_rule = '@charset "UTF-8"; .foo { color: black; }'
    assert_equal ['@charset "UTF-8";', ' .foo { color: black; }'], CssSplitter::Splitter.send(:extract_charset, first_rule)
  end

  # --- split_string ---

  test '#split_string to get the second split' do
    assert_equal "@charset \"UTF-8\";\n#test { background-color: green ;}", CssSplitter::Splitter.split_string(File.read('test/dummy/app/assets/stylesheets/too_big_stylesheet.css.scss'), 2)
  end
end
