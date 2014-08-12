module CssSplitter
  module ApplicationHelper
    def split_stylesheet_link_tag(*sources)
      options     = sources.extract_options!
      split_count = options.delete(:split_count) || 2

      sources.map do |source|
        split_sources = (2..split_count).map { |index| "#{ source }_split#{ index }" }

        if Rails.env != 'development'
          lines = [
            stylesheet_link_tag(source, options),
            "<!--[if lte IE 9]>"
          ]

          split_sources.each do |split_source|
            lines << stylesheet_link_tag(split_source, options)
          end
        else
          lines = [
            content_tag(
              :link,
              nil,
              options.
              merge!({
                href: "/assets/#{ sources.first }.css",
                rel: :stylesheet
              })),
            "<!--[if lte IE 9]>"
          ]

          split_sources.each do |split_source|
            lines << content_tag(
                       :link,
                       nil,
                       options.merge({ href: "/assets/#{ split_source }.css" })
                     )
          end
        end
        lines << "<![endif]-->"
        lines
      end.flatten.join("\n").html_safe
    end
  end
end