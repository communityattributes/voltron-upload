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
                name: file.filename,
                size: file.size,
                type: file.content_type
              }
            else
              {}
            end
          end

          def id
            if stored?
              [File.mtime(full_store_path).to_i, file.filename].join('/')
            elsif cached? && File.exists?(Rails.root.join('public', cache_path))
              [cached?, file.filename].join('/')
            else
              file.filename
            end
          end

          def stored?
            File.exists?(full_store_path)
          end

          def full_store_path
            Rails.root.join('public', store_path(file.filename))
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
              if File.exist?(file.path)
                FileUtils.touch file.path, mtime: Time.now + @offset.seconds
              end
            end

        end
      end
    end
  end
end
