module Voltron
  module Upload

#    extend ActiveSupport::Autoload
#
#    autoload :Field
#
#    autoload :CarrierWave
#
#    autoload :Engine

    class Engine < Rails::Engine

      isolate_namespace Voltron

      initializer "voltron.upload.initialize" do
        puts "DEBUG3"
        ::ActionController::Parameters.send :prepend, ::Voltron::Upload::ActionController::Parameters
        ::ActionDispatch::Routing::Mapper.send :include, ::Voltron::Upload::Routes
        #::ActionView::Helpers::FormBuilder.send :prepend, ::Voltron::Upload::Field
        ::ActionController::Base.send :extend, ::Voltron::Upload
        ::CarrierWave::Mount.send :prepend, ::Voltron::Upload::CarrierWave::Mount
        ::CarrierWave::Uploader::Base.send :include, ::Voltron::Upload::CarrierWave::Uploader::Base

        ActiveSupport.on_load :active_record do
          require 'voltron/upload/field'
          ::ActionView::Helpers::FormBuilder.send :prepend, ::Voltron::Upload::Field
        end
      end

    end
  end
end
