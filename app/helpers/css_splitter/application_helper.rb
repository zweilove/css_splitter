module CssSplitter
  module ApplicationHelper
    def split_stylesheet_link_tag(*sources)
      original_sources = sources.dup

      options = sources.extract_options!
      sources.collect!{ |source| "#{source}_split2" }
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