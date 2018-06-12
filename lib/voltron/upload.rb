require 'voltron'
require 'carrierwave'
require 'voltron/upload/version'
require 'voltron/config/upload'
require 'voltron/upload/error'
require 'voltron/uploader'
require 'voltron/upload/carrierwave/uploader/base'
require 'voltron/upload/active_record/base'
require 'voltron/upload/action_dispatch/routes'

module Voltron
  module Upload

    LOG_COLOR = :light_cyan

    def uploadable(resource = nil)
      include ControllerMethods

      resource ||= controller_name
      @uploader ||= Voltron::Uploader.new(resource)

      rescue_from ActionController::InvalidAuthenticityToken do |e|
        raise unless action_name == 'upload'
        render json: { success: false, error: 'Invalid authenticity token provided' }, status: :unauthorized
      end
    end

    module ControllerMethods

      def upload
        begin
          render json: uploader.process!(upload_params), status: :created
        rescue Voltron::Upload::Error => e
          render json: e.response, status: e.status
        end
      end

      def uploader
        self.class.instance_variable_get('@uploader')
      end

      def upload_params
        request.parameters[uploader.resource_name].slice(*uploader.permitted_params)
      end

    end

  end
end

require "voltron/upload/engine" if defined?(Rails)
