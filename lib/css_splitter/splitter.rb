module CssSplitter

  class Splitter

    MAX_SELECTORS_DEFAULT = 4095

    # returns the specified split of the passed css_string
    def self.split_string(css_string, split = 1, max_selectors = MAX_SELECTORS_DEFAULT)
      rules = split_string_into_rules(css_string)
      extract_part rules, split, max_selectors
    end

    # splits string into array of rules (also strips comments)
    def self.split_string_into_rules(css_string)
      strip_comments(css_string).chomp.scan /[^}]*}/
    end

    # extracts the specified part of an overlong CSS string
    def self.extract_part(rules, part = 1, max_selectors = MAX_SELECTORS_DEFAULT)
      return if rules.first.nil?

      charset_statement, rules[0] = extract_charset(rules.first)
      return if rules.nil?

      output = charset_statement || ""
      selectors_count = 0
      selector_range = max_selectors * (part - 1) + 1 .. max_selectors * part # e.g (4096..8190)

      rules.each do |rule|
        rule_selectors_count = count_selectors_of_rule rule
        selectors_count += rule_selectors_count

        if selector_range.cover? selectors_count # add rule to current output if within selector_range
          output << rule
        elsif selectors_count > selector_range.end # stop writing to output
          break
        end
      end

      output
    end

    # count selectors of one individual CSS rule
    def self.count_selectors_of_rule(rule)
      strip_comments(rule).partition(/\{/).first.scan(/,/).count.to_i + 1
    end



    # count selectors of a CSS stylesheet (not used by SprocketsEngine)
    def self.count_selectors(css_file)
      raise "file could not be found" unless File.exists? css_file

      rules = split_string_into_rules(File.read css_file)
      return if rules.first.nil?

      rules.sum{ |rule| count_selectors_of_rule(rule) }
    end



    private

      # extracts potential charset declaration from the first rule
      def self.extract_charset(rule)
        if rule.include?('charset')
          rule.partition(/^\@charset[^;]+;/)[1,2]
        else
          [nil, rule]
        end
      end

      def self.strip_comments(s)
        s.gsub(/\/\*.*?\*\//m, "")
      end

  end

end
