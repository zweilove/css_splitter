require 'tilt'

module CssSplitter

  class SprocketsEngine < Tilt::Template
    def self.engine_initialized?
      true
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      split = if scope.pathname.extname =~ /(\d+)$/; $1
              elsif scope.pathname.basename.to_s =~ /_split(\d+)\.css/; $1
              else 2
              end
      CssSplitter::Splitter.split_string data, split.to_i, CssSplitter.config.max_selectors
    end
  end
end
