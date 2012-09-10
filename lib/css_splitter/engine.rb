module CssSplitter
  class Engine < ::Rails::Engine
    isolate_namespace CssSplitter

    initializer 'css_splitter.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper CssSplitter::ApplicationHelper
      end
    end
  end
end
