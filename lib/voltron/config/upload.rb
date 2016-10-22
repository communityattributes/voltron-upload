module Voltron
  class Config

    def upload
      @upload ||= Upload.new
    end

    class Upload

      attr_accessor :enabled

      def initialize
        @enabled ||= true
      end
    end
  end
end