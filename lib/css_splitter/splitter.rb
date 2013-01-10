module CssSplitter

  class Splitter

    MAX_SELECTORS_DEFAULT = 4095

    def self.split(infile, outdir = File.dirname(infile), max_selectors = MAX_SELECTORS_DEFAULT)

      raise "infile could not be found" unless File.exists? infile

      rules = IO.readlines(infile, "}")
      return if rules.first.nil?

      charset_statement, rules[0] = rules.first.partition(/^\@charset[^;]+;/)[1,2]
      return if rules.nil?

      file_id = 1 # The infile remains the first file
      selectors_count = 0
      output = nil

      rules.each do |rule|
        rule_selectors_count = count_selectors_of_rule rule
        selectors_count += rule_selectors_count

        # Nothing happens until the selectors limit is reached for the first time
        if selectors_count > max_selectors
          # Close current file if there is already one
          output.close if output

          # Prepare next file
          file_id += 1
          filename = File.join(outdir, File.basename(infile, File.extname(infile)) + "_#{file_id.to_s}" + File.extname(infile))
          output = File.new(filename, "w")
          output.write charset_statement

          # Reset count with current rule count
          selectors_count = rule_selectors_count
        end

        output.write rule if output
      end
    end

    def self.split_string(css_string, part = 1, max_selectors = MAX_SELECTORS_DEFAULT)
      rules = split_string_into_rules(css_string)
      extract_part rules, part, max_selectors
    end

    def self.split_string_into_rules(css_string)
      strip_comments(css_string).chomp.scan /[^}]*}/
    end

    def self.extract_part(rules, part = 1, max_selectors = MAX_SELECTORS_DEFAULT)
      return if rules.first.nil?

      charset_statement, rules[0] = rules.first.partition(/^\@charset[^;]+;/)[1,2]
      return if rules.nil?

      output = charset_statement
      selectors_count = 0
      selector_range = max_selectors * (part - 1) + 1 .. max_selectors * part

      rules.each do |rule|
        rule_selectors_count = count_selectors_of_rule rule
        selectors_count += rule_selectors_count

        if selector_range.cover? selectors_count
          output << rule
        elsif selectors_count > selector_range.end
          break
        end
      end

      output
    end

    # count selectors of a CSS stylesheet
    def self.count_selectors(css_file)
      raise "file could not be found" unless File.exists? css_file

      # get all the rules of the stylesheet using the closing '}'
      rules = IO.readlines(css_file, '}')
      return if rules.first.nil?

      rules.sum{ |rule| count_selectors_of_rule(rule) }.tap do |result|
        puts File.basename(css_file) + " contains #{result} selectors."
      end
    end

    # count selectors of one individual CSS rule
    def self.count_selectors_of_rule(rule)
      strip_comments(rule).partition(/\{/).first.scan(/,/).count.to_i + 1
    end

    private

      def self.strip_comments(s)
        s.gsub(/\/\*.*?\*\//m, "")
      end

  end

end
