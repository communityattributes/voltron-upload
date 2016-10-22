require "voltron"
require "voltron/config/upload"
require "voltron/upload/version"
require "voltron/upload/routes"
require "voltron/upload/error"
require "voltron/upload/invalid_error"
require "voltron/upload/action_controller/parameters"
require "voltron/upload/carrierwave/uploader/base"
require "voltron/upload/carrierwave/mount"
require "voltron/uploader"

module Voltron
  module Upload

    def uploadable(resource = nil)
      include ControllerMethods

      resource ||= controller_name.classify
      @uploader ||= Voltron::Uploader.new(resource)

      before_action :add_commit_params

      before_action :add_permit_params

    end

    module ControllerMethods

      def upload
        begin
          render json: uploader.process!(upload_params), status: :created
        rescue Voltron::Upload::InvalidError => e
          render json: e.response, status: e.status
        end
      end

      def add_permit_params
        params.uploader = uploader
      end

      def add_commit_params
        params.add_commit_params_for(uploader)
      end

      def uploader
        self.class.instance_variable_get("@uploader")
      end

      def upload_params
        params.require(uploader.resource_name.to_sym).permit(uploader.permitted_params)
      end

    end

  end
end

require "voltron/upload/engine" if defined?(Rails)
