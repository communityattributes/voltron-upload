module Voltron
  module Upload
    class InvalidError < ::Voltron::Upload::Error

      def status
        :not_acceptable
      end

    end
  end
end