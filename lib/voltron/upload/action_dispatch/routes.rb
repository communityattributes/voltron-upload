module Voltron
  module Upload
    module Routes

      def upload_for(*resources)
        resources.each do |resource|
          controller = resource.to_s.underscore
          post "/#{controller}/upload", to: "#{controller}#upload", as: "upload_#{controller}"
        end
      end

    end
  end
end
