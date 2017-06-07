Voltron.setup do |config|

  # === Voltron Upload Configuration ===

  # Whether or not calls to file_field should generate markup for dropzone uploads
  # If false, simply returns what file_field would return normally
  # config.upload.enabled = true

  # How long temporarily uploaded files should remain on the server and in the voltron_temp db table
  # This value should be long enough to give any user filling out a form a reasonable amount of time to come
  # back and submit it. In other words, don't make it 5 minutes, or the files the user uploads will not exist
  # when they get around to clicking the "submit" button
  # Keep in mind that all of the above applies only if you add the following to your schedule.rb file for whenever
  #
  # every 1.day do
  #   runner "Voltron::Upload::Tasks.cleanup"
  # end
  #
  # config.upload.keep_for = 30.days

  # Global defaults for Dropzone's with a defined preview template
  # Should be a hash of keys matching a preview partial name,
  # with a value hash containing any of the Dropzone configuration options
  # found at http://www.dropzonejs.com/#configuration-options
  # config.upload.previews = {
  #   vertical_tile: {
  #     thumbnailWidth: 200,
  #     thumbnailHeight: 175,
  #     dictRemoveFile: 'Remove',
  #     dictCancelUpload: 'Cancel'
  #   },
  # 
  #   horizontal_tile: {
  #     dictRemoveFile: 'Remove',
  #     dictCancelUpload: 'Cancel'
  #   }
  # }

  # === Voltron Base Configuration ===

  # Whether to enable debug output in the browser console and terminal window
  config.debug = true

  # The base url of the site. Used by various voltron-* gems to correctly build urls
  # Defaults to Rails.application.config.action_controller.default_url_options[:host], or 'localhost:3000' if not set
  config.base_url = 'http://localhost:3000'

  # What logger calls to Voltron.log should use
  config.logger = Logger.new(Rails.root.join('log', 'voltron.log'))

end
