require 'tilt'

module CssSplitter

  class SprocketsEngine < Tilt::Template
    def self.engine_initialized?
      true
    end

    def prepare
    end

    def self.call(input)
      data_in = input[:data]

      # Instantiate Sprockets::Context to pass along helper methods for Tilt
      # processors
      context = input[:environment].context_class.new(input)

      # Pass the asset file contents as a block to the template engine,
      # then get the results of the engine rendering
      engine = self.new { data_in }
      rendered_data = engine.render(context, {})

      # Return the data and any metadata (ie file dependencies, etc)
      context.metadata.merge(data: rendered_data.to_str)
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
