require "css_splitter/engine"
require "css_splitter/sprockets_engine"
require "css_splitter/splitter"

module CssSplitter
  def self.config(&block)
    @@config ||= begin
      engine = Engine::Configuration.new
      engine.number_of_splits = 2
      engine.max_selectors = 4095
      engine
    end

    yield @@config if block

    return @@config
  end
end
