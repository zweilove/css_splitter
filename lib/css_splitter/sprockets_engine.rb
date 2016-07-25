require 'tilt'

module CssSplitter

  class SprocketsEngine < Tilt::Template
    def self.engine_initialized?
      true
    end

    def prepare
    end

    def self.call(input)
      filename = input[:filename]
      data     = input[:data]
      context  = input[:environment].context_class.new(input)

      data = self.new(filename) { data }.render(context, {})
      context.metadata.merge(data: data.to_str)
    end

    def evaluate(scope, locals, &block)
      # Evaluate the split if the asset is named with a trailing _split2, _split3, etc.
      if scope.logical_path =~ /_split(\d+)$/
        CssSplitter::Splitter.split_string(data, $1.to_i)
      else
        data
      end
    end
  end

end
