if defined? Rails
  require 'css_splitter/railtie'
  require 'css_splitter/engine'
end

require "css_splitter/sprockets_engine"
require "css_splitter/splitter"

module CssSplitter
end
