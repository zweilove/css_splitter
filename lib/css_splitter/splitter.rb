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
      partial_rules = strip_comments(css_string).chomp.scan /[^}]*}/
      whole_rules = []
      bracket_balance = 0
      in_media_query = false

      partial_rules.each do |rule|
        if rule =~ /^@media/
          in_media_query = true
        elsif bracket_balance == 0
          in_media_query = false
        end

        if bracket_balance == 0 || in_media_query
          whole_rules << rule
        else
          whole_rules.last << rule
        end

        bracket_balance += get_rule_bracket_balance rule
      end

      whole_rules
    end

    # extracts the specified part of an overlong CSS string
    def self.extract_part(rules, part = 1, max_selectors = MAX_SELECTORS_DEFAULT)
      return if rules.first.nil?

      charset_statement, rules[0] = extract_charset(rules.first)
      return if rules.nil?

      output = charset_statement || ""
      selectors_count = 0
      selector_range = max_selectors * (part - 1) + 1 .. max_selectors * part # e.g (4096..8190)

      current_media = nil
      selectors_in_media = 0
      first_hit = true
      rules.each do |rule|
        media_part = extract_media(rule)
        if media_part
          current_media = media_part
          selectors_in_media = 0
        end

        rule_selectors_count = count_selectors_of_rule rule
        selectors_count += rule_selectors_count

        if rule =~ /\A\s*}\z$/
          current_media = nil
          # skip the line if the close bracket is the first rule for the new file
          next if first_hit
        end

        if selector_range.cover? selectors_count # add rule to current output if within selector_range
          if media_part
            output << media_part
          elsif first_hit && current_media
            output << current_media
          end
          selectors_in_media += rule_selectors_count if current_media.present?
          output << rule
          first_hit = false
        elsif selectors_count > selector_range.end # stop writing to output
          break
        end
      end

      if current_media.present? and selectors_in_media > 0
        output << '}'
      end

      output
    end

    # count selectors of one individual CSS rule
    def self.count_selectors_of_rule(rule)
      parts = strip_comments(rule).partition(/\{/)
      parts.second.empty? ? 0 : parts.first.scan(/,/).count.to_i + 1
    end



    # count selectors of a CSS stylesheet (not used by SprocketsEngine)
    def self.count_selectors(css_file)
      raise "file could not be found" unless File.exists? css_file

      rules = split_string_into_rules(File.read css_file)
      return if rules.first.nil?

      rules.sum{ |rule| count_selectors_of_rule(rule) }
    end



    private

      def self.extract_media(rule)
        if rule.sub!(/^\s*(@media[^{]*{)([^{}]*{[^}]*})$/) { $2 }
          $1
        end
      end

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

      def self.get_rule_bracket_balance ( rule )
        rule.scan( /}/ ).size - rule.scan( /{/ ).size
      end

  end

end
