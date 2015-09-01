require 'test_helper'

class CssSplitterTest < ActiveSupport::TestCase
  test "#count_selectors" do
    assert_equal 2937, CssSplitter::Splitter.count_selectors('test/unit/too_many_selectors.css')
  end

  test "#count_selectors_of_rule" do
    assert_equal 1, CssSplitter::Splitter.count_selectors_of_rule('foo { color: baz; }')
    assert_equal 2, CssSplitter::Splitter.count_selectors_of_rule('foo, bar { color: baz; }')

    # split_string_into_rules splits the closing brace of a media query into its own rule
    assert_equal 0, CssSplitter::Splitter.count_selectors_of_rule('}')
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

  test '#split_string_into_rules containing media queries' do
    has_media = "a{foo:bar;}@media print{b{baz:qux;}c{quux:corge;}}d{grault:garply;}"
    assert_equal ["a{foo:bar;}", "@media print{b{baz:qux;}", "c{quux:corge;}", "}", "d{grault:garply;}"], CssSplitter::Splitter.split_string_into_rules(has_media)
  end

  test "#split_string_into_rules containing keyframes" do
    has_keyframes = "a{foo:bar;}@keyframes rubes{from{baz:qux;}50%{quux:corge;}}d{grault:garply;}"
    assert_equal ["a{foo:bar;}", "@keyframes rubes{from{baz:qux;}50%{quux:corge;}}", "d{grault:garply;}"], CssSplitter::Splitter.split_string_into_rules(has_keyframes)
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

  # --- extract_media ---

  test '#extract_media with no media block' do
    first_rule = ".foo { color: black; }"
    assert_equal nil, CssSplitter::Splitter.send(:extract_media, first_rule)
  end

  test '#extract_media with media block' do
    first_rule = <<EOD
@media only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 768px), only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 1280px), only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 800px) {
  .foo { color: black; }
}
EOD
    assert_equal '@media only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 768px), only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 1280px), only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 800px) {', CssSplitter::Splitter.send(:extract_media, first_rule)
  end

  # --- split_string ---

  test '#split_string to get the second split' do
    assert_equal "@charset \"UTF-8\";\n#test { background-color: green ;}", CssSplitter::Splitter.split_string(File.read('test/dummy/app/assets/stylesheets/too_big_stylesheet.css.scss'), 2)
  end

  test '#split_string where the media part would overlap the split, all rules in media before the split, closing would end up in second part' do
    # This tests the following situation:
    # Part 1: CssSplitter::Splitter::MAX_SELECTORS_DEFAULT - 1
    #         + Media block and first rule inside the media block
    # Part 2: Ignore the close tag of the media block and outputs the last rule outside the media block

    # Change this line to any number, for example 4, if it fails to ease debugging
    max_selectors = CssSplitter::Splitter::MAX_SELECTORS_DEFAULT

    css_rules = []
    (max_selectors - 1).times do |n|
      css_rules << ".a#{n} { color: black; }"
    end
    css_rules << "@media only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 768px), only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 1280px), only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 800px) {"
    css_rules << ".first-in-media-after-split { color: black; } }"
    last_part = ".first-after-media { color: black; }"

    first_contents = css_rules.join("").gsub(/\s/, '')
    last_contents = last_part.gsub(/\s/, '')
    css_contents = "#{first_contents}#{last_contents}"

    assert_equal first_contents, CssSplitter::Splitter.split_string(css_contents, 1, max_selectors)
    assert_equal last_contents, CssSplitter::Splitter.split_string(css_contents, 2, max_selectors)
  end

  test '#split_string where the media part would overlap the split, no rules in media before the split' do
    # This tests the following situation:
    # Part 1: CssSplitter::Splitter::MAX_SELECTORS_DEFAULT
    # Part 2: Opens with media block with 1 rule inside and one after

    # Change this line to any number, for example 4, if it fails to ease debugging
    max_selectors = CssSplitter::Splitter::MAX_SELECTORS_DEFAULT

    css_rules = []
    max_selectors.times do |n|
      css_rules << ".a#{n} { color: black; }"
    end
    media_rule = "@media only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 768px), only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 1280px), only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 800px) {"
    last_part = "#{media_rule} .first-in-media-after-split { color: black; } } .first-after-media { color: black; }"

    first_contents = css_rules.join("").gsub(/\s/, '')
    last_contents = last_part.gsub(/\s/, '')
    css_contents = "#{first_contents}#{last_contents}"

    assert_equal first_contents, CssSplitter::Splitter.split_string(css_contents, 1, max_selectors)
    assert_equal last_contents, CssSplitter::Splitter.split_string(css_contents, 2, max_selectors)
  end

  test '#split_string where the media part would overlap the split, with rules in media before the split' do
    # This tests the following situation:
    # Part 1: CssSplitter::Splitter::MAX_SELECTORS_DEFAULT - 1 rules
    #         + Media block and first rule inside the media block
    # Part 2: Opens with media block with last rule inside and one after

    # Change this line to any number, for example 4, if it fails to ease debugging
    max_selectors = CssSplitter::Splitter::MAX_SELECTORS_DEFAULT

    css_rules = []
    (max_selectors - 1).times do |n|
      css_rules << ".a#{n} { color: black; }"
    end
    css_rules << media_rule = "@media only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 768px), only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 1280px), only screen and (-webkit-min-device-pixel-ratio: 0) and (device-width: 800px) {"
    css_rules << ".last-before-split { color: black; }"

    after_split = ".last-after-split { color: black; } } .first-after-media { color: black; }".gsub(/\s/, '')

    first_contents = css_rules.join("").gsub(/\s/, '')
    css_contents = "#{first_contents}#{after_split}"

    # The last part should open with the media, followed by the rules defined in after_split
    last_contents = "#{media_rule}#{after_split}".gsub(/\s/, '')

    # The first file should be closed neatly, as the media part opened before the last rule
    # it should be closed as well.
    assert_equal "#{first_contents}}", CssSplitter::Splitter.split_string(css_contents, 1, max_selectors)

    # The second part should open with the media definition, followed by one rule inside
    # the media block and one rule after.
    assert_equal last_contents, CssSplitter::Splitter.split_string(css_contents, 2, max_selectors)
  end

  test '#split_string where the media part comes before the split' do
    # This tests the following situation:
    # Part 1: Media block with rule inside media block
    #         + CssSplitter::Splitter::MAX_SELECTORS_DEFAULT - 1 rules outside media block
    # Part 2: Outputs the last rule outside media block

    # Change this line to any number, for example 4, if it fails to ease debugging
    max_selectors = CssSplitter::Splitter::MAX_SELECTORS_DEFAULT

    css_rules = []
    css_rules << "@media print { .media-rule { color: black; } }"

    (max_selectors - 1).times do |n|
      css_rules << ".a#{n} { color: black; }"
    end

    first_contents = css_rules.join("").gsub(/\s/, '')
    last_contents = ".first-after-split { color: black; }".gsub(/\s/, '')

    css_contents = "#{first_contents}#{last_contents}"

    assert_equal first_contents, CssSplitter::Splitter.split_string(css_contents, 1, max_selectors)
    assert_equal last_contents, CssSplitter::Splitter.split_string(css_contents, 2, max_selectors)
  end

  # --- strip_comments ---

  test '#strip_comments:  strip single line CSS coment' do
    assert_equal ".foo { color: black; }\n.foo { color: black; }", CssSplitter::Splitter.send(:strip_comments, ".foo { color: black; }\n/* comment */.foo { color: black; }")
  end

  test '#strip_comments:  strip multiline CSS coment' do
    assert_equal ".foo { color: black; }\n.foo { color: black; }", CssSplitter::Splitter.send(:strip_comments, ".foo { color: black; }\n/* multi\nline\ncomment */.foo { color: black; }")
  end
end
