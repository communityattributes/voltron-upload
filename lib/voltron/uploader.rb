module Voltron
  class Uploader

    attr_accessor :resource

    def initialize(resource)
      @resource = resource.to_s.classify.safe_constantize
    end

    # Resource name as it would appear in the params hash
    def resource_name
      resource.name.singularize.underscore.to_sym
    end

    # List of permitted parameters needed for upload action
    def permitted_params
      columns.keys.map(&:to_sym)
      #.map { |name, multiple| multiple ? { name => [] } : name }
    end

    def process!(params)
      params = params.map { |column, value| { column => multiple?(column) && value.is_a?(Array) ? value.map(&:values).flatten : value } }.reduce(Hash.new, :merge)
      model = resource.new(params)

      # Test the validity, get the errors if any
      model.valid?

      # Remove all errors that were not related to an uploader, they're expected in this case
      (model.errors.keys - resource.uploaders.keys).each { |k| model.errors.delete k }

      if model.errors.any?
        # If any errors, return the messages
        raise ::Voltron::Upload::Error.new(model.errors.full_messages)
      else
        { uploads: files_from(model) }
      end
    end

    def files_from(model)
      model.slice(columns.keys).values.flatten.reject(&:blank?).map(&:to_upload_json)
    end

    # Get a hash of uploader columns and whether or not it accepts multiple uploads
    # i.e. - { column => multiple_uploads? }
    # i.e. - { avatar: false }
    def columns
      @instance ||= resource.new
      uploaders = resource.uploaders.keys.map(&:to_s)
      resource.uploaders.map { |k,v| { k.to_s => multiple?(k) } }.reduce(Hash.new, :merge)
    end

    def multiple?(column)
      @instance ||= resource.new
      @instance.respond_to?("#{column}_urls")
    end

  end
end
