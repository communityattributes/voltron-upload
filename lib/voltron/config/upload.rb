module Voltron
  class Config

    def upload
      @upload ||= Upload.new
    end

    class Upload

      attr_accessor :enabled, :previews

      def initialize
        @enabled ||= true
        @previews ||= {}
      end
    end
  end
end