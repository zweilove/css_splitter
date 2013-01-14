require 'tilt'

module CssSplitter

  class SprocketsEngine < Tilt::Template
    def self.engine_initialized?
      true
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      split = scope.pathname.extname =~ /(\d+)$/ && $1 || 0 # determine which is the current split (e.g. split2, split3)
      CssSplitter::Splitter.split_string data, split.to_i
    end
  end

end