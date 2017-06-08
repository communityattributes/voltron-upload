[![Coverage Status](https://coveralls.io/repos/github/ehainer/voltron-upload/badge.svg?branch=master)](https://coveralls.io/github/ehainer/voltron-upload?branch=master)
[![Build Status](https://travis-ci.org/ehainer/voltron-upload.svg?branch=master)](https://travis-ci.org/ehainer/voltron-upload)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

# Voltron::Upload

Voltron upload brings [Dropzone JS](http://www.dropzonejs.com/) and logical file upload & committing to rails resources. It is an attempt to solve the issue of dropzone js uploading files immediately, often times before the resource itself has been saved (i.e. - User registration, where one might be able to upload an avatar)

The nice feature of Voltron Upload is that it requires very little additional code outside of what would be required by [CarrierWave](https://github.com/carrierwaveuploader/carrierwave) and gracefully can fall back to default file field inputs in the event that Dropzone is not supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'voltron-upload', '~> 0.2.0'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install voltron-upload

Then run the following to create the voltron.rb initializer (if not exists already) and add the upload config:

    $ rails g voltron:upload:install

Also, include the necessary js and css by adding the following to your application.js and application.css respectively

```javascript
//= require voltron-upload
```

```css
/*
 *= require voltron-upload
 */
```

If you want to customize the out-of-the-box functionality or styles, you can copy the assets (javascript/css) to your app assets directory by running:

    $ rails g voltron:upload:install:assets
    
Optionlly, you may copy the few out-of-the-box preview template views to your app by running:

    $ rails g voltron:upload:install:views
    
The views will be installed in the directory `<rails_root>/app/views/voltron/upload/preview/`

## Usage

Voltron upload is designed to work as seamlessly as possible with how native carrierwave functionality does. Given a model `User`, you could have something like the following:

```ruby
class User < ActiveRecord::Base

  mount_uploader :avatar, AvatarUploader

  mount_uploaders :images, ImageUploader # For multiple uploads

end
```

Your controller only needs a call to `uploadable` to include the necessary route actions:

```ruby
class UsersController < ApplicationController

  uploadable :user

end
```

The only argument to `uploadable` is the name of the model you'll be associating the uploads with, and is also optional. If omitted, Voltron Upload will try to determine it by the controller name. A controller named `UsersController` will look for a model named `User`, `PeopleController` will look for a model named `Person`, etc... If you have any doubts in it's ability to determine the model, just define it like shown above.

Lastly, you need to include the routes in your routes.rb config file:

```ruby
Rails.application.routes.draw do

  upload_for :people
  
  # Or, explicitly define route parameters

  # Will route the path to 'person#upload' as `upload_people_path`/`upload_people_url`
  upload_for :people, { path: '/person/upload', controller: :person }

end
```

As for your markup, Voltron Upload overrides the `file_field` helper method, but the options remain the same so nothing out of the ordinary needs to change. However, additional parameters are possible:

| Parameter | Default | Comment                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|-----------|---------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| default   | false   | If true, forces the file_field to fallback to the default file field input.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| preserve  | true    | If false, causes uploaded files to not persist in the Dropzone container. Useful for one-off uploads that trigger something else, like image cropping functionality. In that case you likely wouldn't want the uploaded files preview container to be visible, since you'd likely have just a progress bar instead.                                                                                                                                                                                                                                                                                              |
| preview   | nil     | Can be either the name of a preview partial found in `app/views/voltron/upload/preview` or raw html markup representing the Dropzone preview. If the defined preview partial name could not be found, or is not defined, it will fallback to the [default dropzone preview template](http://www.dropzonejs.com/#layout). Note that it will attempt to parse the preview template name even if html is provided, by stripping away all markup and using the leftover text as the preview name. i.e. - `preview: :progress` is seen the same as `preview: '<div style="height: 1px;"><span>progress</span></div>'` |
| options   | nil     | If defined, should be a hash of [Dropzone JS configuration options](http://www.dropzonejs.com/#configuration-options). Options defined here override the global configuration options of the matching preview, if any (see: Configuration) Hash keys can be defined as either camelCase or snake_case. (i.e. - dictDefaultMessage or dict_default_message)                                                                                                                                                                                                                                                       |

## Configuration

There are two global config settings that will be found in `config/initializers/voltron.rb` once the installer is run.

| Option   | Default    | Comment                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
|----------|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| enabled  | true       | Whether or not the file input fields should be converted to Dropzones. The master on/off switch for the whole thing.                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| previews | empty hash | Sets global Dropzone JS configuration settings for Dropzones utilizing a matching preview template. Running the installer will include some preview settings for out-of-the-box preview templates, which can be a good reference. The general format is that of a nested hash, where each key maps to a preview view name, and the value is a hash of options for Dropzones utilizing that preview template, i.e. - `{ preview_name: { dictDefaultMessage: 'Drop files here', parallelUploads: 10, etc... } }`|

## Theming

Voltron Upload comes preloaded with 3 [preview template themes](http://www.dropzonejs.com/#layout), a horizontal tile layout, vertical tile layout, and progress bar layout. If/when you decide to add new preview templates, they should be added as partial views in the `app/views/voltron/upload/preview/` directory. The name of the view then defines the preview name when used in conjunction with the `file_field` method:

```ruby
<%= f.file_field :avatar, preview: :horizontal_tile # maps to the _horizontal_tile.html.erb view %>
```
as well as ties to the associated global config:
```ruby
Voltron.setup do |config|
  config.upload.previews = {
    horizontal_tile: {
      dictDefaultMessage: 'Drop files here',
      dictCancelUpload: 'Cancel',
      parallelUploads: 10,
      # and so on...
    }
  }
end
```

If the preview template name defined maps to an existing preview view (in the above case, `app/views/voltron/upload/preview/_horizontal_tile.html.erb`) an additional css class will be added to the Dropzone wrapper element matching the format `dz-layout-<preview name>`, i.e. - `dz-layout-horizontal_tile`

From there, you can theme using the generated class name from within voltron-upload.scss. If the file is not in your assets directory run the views installer to add it. (see Installation above)

## Events

Several events are dispatched throughout the course of the upload process, listed with each event's arguments below. Note that in keeping with the Voltron standard of each dispatched object having a `data`, `event`, and `element` parameter, each will appear in the dispatched object. However, whether or not all 3 parameters have content varies. Not all events below have "data" associated, so while `data` will appear in the dispatched object, it is possible to be empty. See the specifics of each event to understand.

To observe any of the events, simply define the listed **callback function** in any other Voltron module of your choosing. The single argument will be an object containing the listed data (keys)

| Event Name         | Callback Function   | Data                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | Comment                                                                                                                                                                                     |
|--------------------|---------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| upload:initialized | onUploadInitialized | <ul><li>**upload:** The Voltron Upload JS instance</li> <li>**dropzone:** The Dropzone instance</li> <li>**element:** The DOM element of the hidden file input field</li></ul>                                                                                                                                                                                                                                                                                                                                                                                          | Dispatched after a Dropzone is instantiated on a given field upload field.                                                                                                                  |
| upload:sending     | onUploadSending     | <ul><li>**upload:** The Voltron Upload JS instance</li> <li>**form:** The DOM element of the form that wraps the Dropzone</li> <li>**file:** An instance of a javascript [File](https://developer.mozilla.org/en-US/docs/Web/API/File)</li> <li>**xhr:** An instance of an [XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) object</li> <li>**data:** An instance of javascript's [FormData](https://developer.mozilla.org/en-US/docs/Web/API/FormData)</li> <li>**element:** The DOM element of the hidden file input field</li></ul> | Dispatched prior to a file being uploaded. Can be observed with the purposes of injecting additional fields into the FormData, or to manipulate the AJAX request before the request is sent |
| upload:complete    | onUploadComplete    | <ul><li>**upload:** The Voltron Upload JS instance</li> <li>**file:** An instance of a javascript [File](https://developer.mozilla.org/en-US/docs/Web/API/File)</li> <li>**data:** The resulting JSON from the upload process. Will contain information about the uploaded file (size, url, etc.)</li> <li>**element:** The DOM element of the hidden file input field</li></ul>                                                                                                                                                                                        | Dispatched after a file is uploaded successfully                                                                                                                                            |
| upload:removed     | onUploadRemoved     | <ul><li>**upload:** The Voltron Upload JS instance</li><li>**file:** An instance of a javascript [File](https://developer.mozilla.org/en-US/docs/Web/API/File)</li><li>**element:** The DOM element of the hidden file input field</li></ul>                                                                                                                                                                                                                                                                                                                            | Dispatched after a file is removed from the Dropzone. This does not mean that the file has actually been deleted, just that it's been "flagged" for deleting when the form is submitted     |
| upload:error       | onUploadError       | <ul><li>**upload:** The Voltron Upload JS instance</li><li>**file:** An instance of a javascript [File](https://developer.mozilla.org/en-US/docs/Web/API/File)</li><li>**data:** Will always be an array of one or more error messages</li><li>**element:** The DOM element of the hidden file input field</li></ul>                                                                                                                                                                                                                                          | Dispatched whenever an error occurs. Look to the `response` argument for the resulting message(s)                                                                                           |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ehainer/voltron-notify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.en.html).

