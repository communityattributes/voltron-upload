module Voltron
  module Upload
    module Base

      extend ActiveSupport::Concern

      included do
        include InstanceMethods

        # Find empty cache directories and remove them
        after_save do
          path = Rails.root.join('public', ::CarrierWave::Uploader::Base.cache_dir, '**', '*')
          Dir[path].select { |d| File.directory? d }.select { |d| (Dir.entries(d) - %w[ . .. ]).empty? }.each { |d| Dir.rmdir d }
        end
      end

      module InstanceMethods
        def is_voltron_uploading?
          voltron_uploading
        end
      end

      module ClassMethods

        def mount_uploader(*args)
          super *args

          column = args.first.to_sym

          attr_accessor "#{column}_cache"

          attr_accessor :voltron_uploading

          before_validation do
            uploader = self.class.uploaders[column]

            begin
              cache_id = send("#{column}_cache")
              send(column).retrieve_from_cache!(cache_id) if cache_id.present?
            rescue ::CarrierWave::InvalidParameter => e
              # Invalid cache id, we don't need to do anything but skip it
            end
          end
        end

        def mount_uploaders(*args)
          super *args

          column = args.first.to_sym

          attr_accessor "#{column}_cache"

          attr_accessor :voltron_uploading

          before_validation do
            uploader = self.class.uploaders[column]
            cache_ids = (JSON.parse(send("#{column}_cache")) rescue []) || []

            # Store the existing files
            files = send(column)

            cache_ids.each do |cache_id|
              begin
                # Retrieve files from the cache and add them to the list of files
                file = uploader.new(self, column)
                file.retrieve_from_cache!(cache_id)
                files << file
              rescue ::CarrierWave::InvalidParameter => e
                # Invalid cache id, we don't need to do anything but skip it
              end
            end

            # Set the files
            send("#{column}=", files)
          end

          # Only required for multiple uploads. Since Carrierwave does not have any way to remove individual files
          # we must identify each file to be removed individually, remove it from the array of existing files,
          # then reset the value of our mounted files
          after_validation do
            # Only attempt to remove files if there are no validation errors
            if errors.empty?
              # Merge any new uploads with the pre-existing uploads (so we can "add" new files, instead of overwriting)
              uploads = Array.wrap(send(column))

              # Get the ids of uploads we want to remove
              removals = Array.wrap(send("remove_#{column}"))

              removals.each do |removal|
                uploads.reject! { |upload| upload.id == removal }
              end

              # Initially ensure carrierwave DOESN'T think we want to remove ALL files, we're just going to change the files (i.e. - remove some, not all)
              send("remove_#{column}=", false)

              # Ensure that nil is assigned as the value if we indeed have no more files
              send("remove_#{column}!") if uploads.empty?

              assign_attributes(column => uploads)
            end
          end
        end
      end

    end
  end
end
