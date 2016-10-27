module Voltron
  class Uploader

    attr_accessor :resource, :params

    def initialize(resource)
      @resource = resource.to_s.classify.safe_constantize
    end

    def instance
      @instance ||= resource.new
    end

    def resource_name
      resource.name.singularize.underscore
    end

    def permitted_params
      resource.uploaders.map do |name,uploader|
        if is_multiple?(name)
          { name => [] }
        else
          name
        end
      end.flatten
    end

    def allowed_params
      resource.uploaders.map do |name,uploader|
        if is_multiple?(name)
          [{ "remove_#{name}" => [] }, { "commit_#{name}" => [] }]
        else
          ["remove_#{name}", "commit_#{name}"]
        end
      end.flatten
    end

    def process!(params)
      # Create a new instance of the resource we're uploading for
      # Pass in the needed upload params and file(s)
      instance.assign_attributes(params)

      # Test the validity, get the errors if any
      instance.valid?

      # Remove all errors that were not related to an uploader, they're expected in this case
      (instance.errors.keys - resource.uploaders.keys).each { |k| instance.errors.delete k }

      if instance.errors.any?
        # If any errors, return the messages
        raise ::Voltron::Upload::Error.new(instance.errors.full_messages)
      else
        response = { uploads: [] }
        # The upload is valid, try to create the "temp" uploads and respond
        params.each do |name,file|
          [file].flatten.each do |f|
            upload = ::Voltron::Temp.new(uuid: unique_id, column: name, file: f, multiple: is_multiple?(name))
            if upload.save
              # Even though we only ever process one file at a time, make sure the response value is an array
              # In the future, we may open it up to process more than one at a time, at which point an array will be important
              # Less changes needed in JS later is all...
              response[:uploads] << upload.uuid
            end
          end
        end
        response
      end
    end

    # Get a hash of uploader columns and whether or not it accepts multiple uploads
    # i.e. - { column => multiple_uploads? }
    # i.e. - { avatar: true }
    def columns
      uploaders = resource.uploaders.keys.map(&:to_s)
      resource.uploaders.map { |k,v| { k.to_s => instance.respond_to?("#{k}_urls") } }.reduce(Hash.new, :merge)
    end

    def is_multiple?(name)
      columns[name.to_s]
    end

    # Probably overkill since we're dealing with UUID's, but better safe than sorry
    def unique_id
      id = ::SecureRandom.uuid

      while ::Voltron::Temp.exists?(uuid: id) do
        id = ::SecureRandom.uuid
      end

      id
    end

  end
end
