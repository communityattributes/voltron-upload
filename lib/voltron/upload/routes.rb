module Voltron
  module Upload
    module Routes

      def upload_for(*resources)
        options = resources.extract_options!

        resources.each do |resource|
          klass = resource.is_a?(Symbol) ? resource.to_s.classify.safe_constantize : resource.to_s.safe_constantize
          if klass
            controller = resource.to_s.underscore
            if klass.try(:uploaders)
              post "/#{controller}/upload", to: "#{controller}#upload", as: "upload_#{controller}"
            end
          else
            Voltron.log "Unable to locate class with constantized name for #{resource}", "Upload", :cyan
          end
        end
      end

    end
  end
end
