module CssSplitter
  class Engine < ::Rails::Engine
    isolate_namespace CssSplitter

    initializer 'css_splitter.sprockets_engine', after: 'sprockets.environment', group: :all do |app|
      app.assets.register_engine '.split2', CssSplitter::SprocketsEngine
    end

    initializer 'css_splitter.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper CssSplitter::ApplicationHelper
      end
    end
  end
end
