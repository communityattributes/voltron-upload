module Voltron
  module Upload
    class Engine < Rails::Engine

      isolate_namespace Voltron

      initializer 'voltron.upload.initialize' do
        ::ActionDispatch::Routing::Mapper.send :include, ::Voltron::Upload::Routes
        ::ActionController::Base.send :extend, ::Voltron::Upload

        ActiveSupport.on_load :active_record do
          require 'voltron/upload/action_view/field'
          ::ActionView::Helpers::FormBuilder.send :prepend, ::Voltron::Upload::Field
          ::CarrierWave::Uploader::Base.send :prepend, ::Voltron::Upload::CarrierWave::Uploader::Base
          ::ActiveRecord::Base.send :include, ::Voltron::Upload::Base
        end
      end
    end
  end
end
