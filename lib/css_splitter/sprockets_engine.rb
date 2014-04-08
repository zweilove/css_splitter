require 'tilt'

module CssSplitter

  class SprocketsEngine < Tilt::Template
    def self.engine_initialized?
      true
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      # determine which is the current split (e.g. split2, split3)
      split = if scope.pathname.extname =~ /(\d+)$/; $1
              elsif scope.pathname.basename.to_s =~ /_split(\d+)\.css/; $1
              else 2
              end
      CssSplitter::Splitter.split_string(data, split.to_i)
    end
  end

end
