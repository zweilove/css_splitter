require 'test_helper'

class CssSplitterTest < ActiveSupport::TestCase
  test "#count_selectors" do
    assert_equal CssSplitter::Splitter.count_selectors('test/unit/too_many_selectors.css'), 2939
  end

  test "#count_selectors_of_rule" do
    assert_equal CssSplitter::Splitter.count_selectors_of_rule('foo { color: baz; }'), 1
    assert_equal CssSplitter::Splitter.count_selectors_of_rule('foo, bar { color: baz; }'), 2
  end
end