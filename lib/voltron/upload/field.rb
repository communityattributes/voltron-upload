module Voltron
  module Upload
    module Field

      def upload_field(method, **options)
        field = UploadField.new(@object, method, options)
        file_field method, field.options
      end

      class UploadField

        include ::ActionDispatch::Routing::PolymorphicRoutes

        include ::Rails.application.routes.url_helpers

        def initialize(model, method, options)
          @model = model
          @method = method.to_sym
          @options = options.deep_symbolize_keys
          prepare
        end

        def options
          @options ||= {}
        end

        def prepare
          options[:multiple] = multiple?
          options[:data] ||= {}
          options[:data][:name] = @method
          options[:data][:files] = files
          options[:data][:commit] = commits
          options[:data][:upload] ||= polymorphic_path(@model.class, action: :upload)
        end

        def multiple?
          @model.respond_to?("#{@method}_urls")
        end

        def single?
          @model.respond_to?("#{@method}_url")
        end

        def files
          if multiple?
            @model.send(@method).map(&:to_upload_hash).compact
          elsif single?
            # Always return an array, makes the js simpler...
            Array.wrap(@model.send(@method).try(:to_upload_hash)).compact
          end
        end

        def commits
          Array.wrap(@model.send("commit_#{@method}")).map do |commit|
            if temp = ::Voltron::Temp.find_by(uuid: commit)
              temp.column == @method.to_s ? commit : nil
            end
          end.compact
        end
      end
    end
  end
end