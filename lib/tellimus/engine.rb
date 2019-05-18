require 'braintree'
require 'bluecloth'
module Tellimus
  class Engine < ::Rails::Engine
    isolate_namespace Tellimus
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    initializer 'tellimus.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        include Tellimus::ApplicationHelper
      end
    end

  end
end
