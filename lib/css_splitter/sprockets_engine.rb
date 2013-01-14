require 'tilt'

module CssSplitter

  class SprocketsEngine < Tilt::Template
    def self.engine_initialized?
      true
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      part = scope.pathname.extname =~ /(\d+)$/ && $1 || 0 # determine which is the current split/part (e.g. split2, split3)
      CssSplitter::Splitter.split_string data, part.to_i
    end
  end

end