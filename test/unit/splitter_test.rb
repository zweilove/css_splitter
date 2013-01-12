require 'test_helper'

class CssSplitterTest < ActiveSupport::TestCase
  test "#count_selectors" do
    assert_equal CssSplitter::Splitter.count_selectors('test/unit/too_many_selectors.css'), 2939
  end

  test "#count_selectors_of_rule" do
    assert_equal CssSplitter::Splitter.count_selectors_of_rule('foo { color: baz; }'), 1
    assert_equal CssSplitter::Splitter.count_selectors_of_rule('foo, bar { color: baz; }'), 2
  end

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
end
