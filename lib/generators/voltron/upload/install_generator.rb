module Voltron
  module Upload
    module Generators
      class InstallGenerator < Rails::Generators::Base

        source_root File.expand_path("../../../templates", __FILE__)

        desc "Add Voltron Upload initializer"

        def inject_initializer

          voltron_initialzer_path = Rails.root.join("config", "initializers", "voltron.rb")

          unless File.exist? voltron_initialzer_path
            unless system("cd #{Rails.root.to_s} && rails generate voltron:install")
              puts "Voltron initializer does not exist. Please ensure you have the 'voltron' gem installed and run `rails g voltron:install` to create it"
              return false
            end
          end

          current_initiailzer = File.read voltron_initialzer_path

          unless current_initiailzer.match(Regexp.new(/# === Voltron Upload Configuration ===/))
            inject_into_file(voltron_initialzer_path, after: "Voltron.setup do |config|\n") do
<<-CONTENT

  # === Voltron Upload Configuration ===

  # Whether or not calls to file_field should generate markup for dropzone uploads
  # If false, simply returns what file_field would return normally
  # config.upload.enabled = true

  # Global defaults for Dropzone's with a defined preview template
  # Should be a hash of keys matching a preview partial name,
  # with a value hash containing any of the Dropzone configuration options
  # found at http://www.dropzonejs.com/#configuration-options
  config.upload.previews = {
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
CONTENT
            end
          end
        end
      end
    end
  end
end