module Voltron
  class Config

    def upload
      @upload ||= Upload.new
    end

    class Upload

      attr_accessor :enabled, :keep_for, :previews

      def initialize
        @enabled ||= true
        @keep_for ||= 30.days
        @previews ||= {
          vertical_tile: {
            thumbnailWidth: 200,
            thumbnailHeight: 175,
            dictRemoveFile: 'Remove',
            dictCancelUpload: 'Cancel'
          },
        
          horizontal_tile: {
            dictRemoveFile: 'Remove',
            dictCancelUpload: 'Cancel'
          }
        }
      end
    end
  end
end