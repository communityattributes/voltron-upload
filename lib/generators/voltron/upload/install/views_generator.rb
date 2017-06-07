module Voltron
  module Upload
    module Generators
      module Install
        class ViewsGenerator < Rails::Generators::Base

          source_root File.expand_path('../../../../../../', __FILE__)

          desc 'Install Voltron Upload views'

          def copy_views
            copy_file 'app/views/voltron/upload/preview/_horizontal_tile.html.erb', Rails.root.join('app', 'views', 'voltron', 'upload', 'preview', '_horizontal_tile.html.erb')
            copy_file 'app/views/voltron/upload/preview/_vertical_tile.html.erb', Rails.root.join('app', 'views', 'voltron', 'upload', 'preview', '_vertical_tile.html.erb')
            copy_file 'app/views/voltron/upload/preview/_progress.html.erb', Rails.root.join('app', 'views', 'voltron', 'upload', 'preview', '_progress.html.erb')
          end

        end
      end
    end
  end
end