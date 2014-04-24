module CssSplitter
  module ApplicationHelper
    def split_stylesheet_link_tag(*sources)
      original_sources = sources.dup

      options = sources.extract_options!
      sources = sources.each_with_object([]) do |source, collection|
        for i in  2..CssSplitter.config.number_of_splits
          collection << "#{source}_split#{i}"
        end
      end
      sources << options

      [
        stylesheet_link_tag(*original_sources),
        "<!--[if lte IE 9]>",
        stylesheet_link_tag(*sources),
        "<![endif]-->"
      ].join("\n").html_safe
    end
  end
end
