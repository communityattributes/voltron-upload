module Voltron
  module Upload
    module CarrierWave
      module Uploader
        module Base

          def initialize(*args)
            self.class.send(:before, :store, :save_timestamp)
            self.class.send(:after, :store, :apply_timestamp)
            super(*args)
          end

          def to_upload_json
            if present?
              {
                id: id,
                url: url,
                name: file.original_filename,
                size: file.size,
                type: file.content_type
              }
            else
              {}
            end
          end

          def id
            if stored?
              [File.mtime(full_store_path).to_i, file.original_filename].join('/')
            elsif cached? && File.exists?(Rails.root.join('public', cache_path))
              [cached?, file.original_filename].join('/')
            else
              file.original_filename
            end
          end

          def stored?
            File.exists?(full_store_path)
          end

          def full_store_path
            Rails.root.join('public', store_path(file.filename))
          end

          # If we're uploading via voltron, just move the file around so it's quicker
          # Possibly a bug, but CarrierWave seems to create duplicate cache files when
          # ActiveRecord's +valid?+ method is called, or the model is instantiated
          # This is my way of currently lessening the number of files that are created
          def move_to_cache
            multiple = model.respond_to?("#{mounted_as}_urls")
            cache = model.send("#{mounted_as}_cache")
            cache = multiple ? (JSON.parse(cache) rescue []) : cache
            Voltron.config.upload.enabled && (model.is_voltron_uploading? || cache.present?) ? true : super
          end

          private

            # Before we store the file for good, grab the offset number
            # so it can be used to create a unique timestamp after storing
            def save_timestamp(*args)
              id_components = File.basename(File.expand_path('..', file.path)).split('-')
              @offset = id_components[2].to_i + 1000
            end

            # Update the modified time of the file to a unique timestamp
            # This timestamp will later be used to help identify the file,
            # as it will be part of the generated id
            def apply_timestamp(*args)
              @offset ||= rand(1..1000)
              FileUtils.touch file.path, mtime: Time.now + @offset.seconds
            end

        end
      end
    end
  end
end
