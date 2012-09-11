module CssSplitter
  class Railtie < Rails::Railtie
    initializer "css_splitter.initializer" do |app|
      app.assets.register_engine '.split2', CssSplitter::SprocketsEngine
    end
  end
end
