module Voltron
  module Upload
    module Field

      include ActionView::Helpers::TagHelper

      def file_field(method, options={})
        if Voltron.config.upload.enabled && !options[:default]
          template = instance_variable_get('@template')
          field = UploadField.new(@object, method, template, options)

          # +merge+ is because options is a hash with_indifferent_access, and will therefore have an 'object' attribute when converted to html
          #super method, {}.merge(field.options)
          content_tag 'v-upload', nil, field.options
        else
          options.delete(:default)
          super method, options
        end
      end

      class UploadField

        include ::ActionDispatch::Routing::PolymorphicRoutes

        include ::Rails.application.routes.url_helpers

        include ::ActionView::Helpers::TextHelper

        attr_reader :options, :template

        def initialize(model, method, template, options)
          @model = model
          @method = method.to_sym
          @template = template
          @options = options.with_indifferent_access
          prepare
        end

        def prepare
          #add_preview_class if has_preview_template?

          options.merge!({
            ':multiple'   => multiple?,
            ':files'      => files.to_json,
            ':cached'     => caches.to_json,
            ':removed'    => removals.to_json,
            ':options'    => preview_options.to_json,
            'accept'      => accept,
            'preview'     => preview_name,
            'param'       => input_name,
            'url'         => polymorphic_path(@model.class, action: :upload)
          })

          #options[:data] ||= {}
          #options[:data].merge!({
          #  upload_files: files,
          #  upload_cache: caches,
          #  upload_remove: removals,
          #  upload_options: preview_options
          #})
        end

        def preview_options
          previews = Voltron.config.upload.previews || {}
          opts = previews.with_indifferent_access.try(:[], preview_name) || {}
          opts.merge!({
            preview_template: preview_markup,
          })
          opts.merge!(options.delete(:options) || {})
          opts.map { |k,v| { k.to_s.camelize(:lower) => v } }.reduce(Hash.new, :merge).compact
        end

        def preview_markup
          if has_preview_template?
            # Fetch the html found in the partial provided
            ActionController::Base.new.render_to_string(partial: "voltron/upload/preview/#{preview_name}").squish
          elsif has_preview_markup?
            # If not blank, value of +preview+ is likely (should be) raw html, in which case, just return that markup
            preview.squish
          end
        end

        # Strip tags, they cause problems in the lookup_context +exists?+ and +render_to_string+
        def preview_name
          strip_tags(preview)
        end

        def preview
          @preview ||= options.delete(:preview).to_s
        end

        def accept
          @accept ||= options.delete(:accept).to_s
        end

        def has_preview_template?
          preview_name.present? && template.lookup_context.exists?(preview_name, 'voltron/upload/preview', true)
        end

        # Eventually, consider utilizing Nokogiri to detect whether content also is actually HTML markup
        # Right now the overhead and frustration of that gem is not worth it
        def has_preview_markup?
          preview.present?
        end

        #def add_preview_class
        #  options[:class] ||= ''
        #  classes = options[:class].split(/\s+/)
        #  classes << "dz-layout-#{preview_name}"
        #  options[:class] = classes.join(' ')
        #end

        def input_name
          ActionView::Helpers::Tags::Base.new(ActiveModel::Naming.param_key(@model), @method, nil).send(:tag_name) + (multiple? ? '[]' : '')
        end

        def multiple?
          @model.respond_to?("#{@method}_urls")
        end

        def files
          # If set to not preserve files, return an empty array so nothing is shown
          return [] if options[:preserve] === false

          # Return an array of files' json data
          uploads = Array.wrap(@model.send(@method)).map(&:to_upload_json).reject(&:blank?)

          # Remove all uploads from the array that have been flagged for removal
          removals.each do |removal|
            uploads.reject! { |upload| upload[:id] == removal }
          end

          uploads
        end

        def caches
          if multiple?
            cache = @model.send("cache_#{@method}") rescue []
            Array.wrap(cache)
          else
            Array.wrap(@model.send("cache_#{@method}"))
          end
        end

        def removals
          Array.wrap(@model.send("remove_#{@method}")).compact.reject { |i| !i }
        end

      end
    end
  end
end