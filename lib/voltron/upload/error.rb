module Voltron
  module Upload
    class Error < StandardError

      attr_accessor :messages

      def initialize(messages)
        @messages = [messages].flatten
      end

      def response
        { success: false, messages: @messages }
      end

      def status
        500
      end
    end
  end
end