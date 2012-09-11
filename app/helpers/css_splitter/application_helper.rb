module CssSplitter
  module ApplicationHelper
    def split_stylesheet_link_tag(*sources)
      forwarded_sources = []

      sources.each do |source|
        puts source.class
        forwarded_sources << source
        forwarded_sources << "#{source}_part2"  if [String, Symbol].include? source.class
      end

      stylesheet_link_tag(*forwarded_sources)
    end
  end
end