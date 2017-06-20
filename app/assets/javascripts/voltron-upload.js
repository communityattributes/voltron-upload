//= require dropzone
//= require voltron

Dropzone.autoDiscover = false;

Voltron.addModule('Upload', function(){

  var _dz = null,
      _form = null;

  var Upload = function(element){

    return {
      initialize: function(){
        _form = this.getInput().closest('form');
        this.createMarkup().createDropzone();
      },

      getInput: function(){
        return $(element);
      },

      getForm: function(){
        return _form;
      },

      isMultiple: function(){
        return this.getInput().prop('multiple');
      },

      getModel: function(){
        return this.getInput().attr('name').match(/^[A-Z_0-9]+/i)[0];
      },

      getMethod: function(){
        return this.getInput().attr('name').match(/^[A-Z_0-9]+\[([A-Z_0-9]+)\]/i)[1];
      },

      getParamName: function(name){
        return this.getModel() + '[' + name + '_' + this.getMethod() + ']' + (this.isMultiple() ? '[]' : '');
      },

      getDropzone: function(){
        return _dz;
      },

      getRemovals: function(){
        return this.getInput().data('upload-remove') || [];
      },

      getFiles: function(){
        return this.getInput().data('upload-files') || [];
      },

      getOptions: function(){
        return this.getInput().data('upload-options');
      },

      addHiddenInputs: function(){
        var removes = this.getRemovals();

        for(var i=0; i<removes.length; i++){
          this.addRemoval(removes[i]);
        }
      },

      addExistingFiles: function(){
        var dz = this.getDropzone(),
            files = this.getFiles(),
            caches = this.getCacheIds();

        // If set to preserve file uploads, iterate through each uploaded file associated with
        // the model and add to the file upload box upon initialization
        // If not set to preserve, the data-files attribute will always be an empty array
        for(var i=0; i<files.length; i++){
          Voltron('Upload/getFileObject', files[i], files[i].id, function(fileObject, id){
            dz.files.push(fileObject);
            dz.options.addedfile.call(dz, fileObject);
            $(fileObject.previewElement).attr('data-id', id);
            $(fileObject.previewElement).addClass('dz-success');
            dz._enqueueThumbnail(fileObject);
            dz.options.complete.call(dz, fileObject);
            dz._updateMaxFilesReachedClass();
          });
        }

        for(var i=0; i<caches.length; i++){
          this.addCache(caches[i]);
        }
      },

      addRemoval: function(id){
        var cache = this.getCache();
        var index = cache.indexOf(id);

        // If the id of the file we want to remove is in the cache input array, remove it
        if(index > -1){
          cache.splice(index, 1);
          if(this.isMultiple()){
            this.getCacheInput().val(JSON.stringify(cache));
          }else{
            this.getCacheInput().val('');
          }
        }

        // Add the removal input field with the given id
        this.getForm().prepend($('<input />', { type: 'hidden', class: 'input-' + id.split('/')[0], name: this.getParamName('remove'), value: id }));
      },

      addCache: function(id){
        if(!/^(-)?[\d]+\-[\d]+(\-[\d]{4})?\-[\d]{4}/.test(id)) return;

        if(this.isMultiple()){
          var cache = this.getCache();
          cache.push(id);
          this.getCacheInput().val(JSON.stringify(cache.uniq()));
        }else{
          this.getCacheInput().val(id);
        }
      },

      getCache: function(){
        try
        {
          if(this.isMultiple()){
            return $.parseJSON(this.getCacheInput().val()) || [];
          }else{
            return [this.getCacheInput().val()];
          }
        }catch(e){
          return [];
        }
      },

      getCacheIds: function(){
        return this.getInput().data('upload-cache');
      },

      getCacheInput: function(){
        var paramName = [this.getModel(), this.getMethod(), 'cache'].join('_');

        if(!this.getForm().find('#' + paramName).length){
          this.getForm().prepend($('<input />', { type: 'hidden', name: this.getModel() + '[' + this.getMethod() + '_cache]', id: paramName, value: (this.isMultiple() ? '[]' : '') }));
        }
        return this.getForm().find('#' + paramName);
      },

      createMarkup: function(){
        if(!this.getInput().closest('.fallback').length) this.getInput().wrap($('<div />', { class: 'fallback' }));
        if(!this.getInput().closest('.dropzone').length) this.getInput().closest('.fallback').wrap($('<div />', { class: 'dropzone' }));
        return this;
      },

      createDropzone: function(){
        _dz = new Dropzone(this.getInput().closest('.dropzone').addClass(this.getInput().get(0).className).get(0), this.getOptions());

        // If the dropzone became a fallback upload input, dz will be a DOM element, not an instance of Dropzone
        if(_dz instanceof Dropzone){
          // Add the dropzone object to the file input, so it's easily accessible
          this.getInput().data('dropzone', _dz);
          this.getInput().data('upload', this);

          // Assign the hidden file input a unique id
          // Not required outside the test environment, but may
          // be useful for other reasons in case one needs to get at the hidden inputs
          $(_dz.hiddenFileInput).attr('id', this.getInput().attr('id') + '_input');

          this.addHiddenInputs();
          this.addExistingFiles();

          _dz.on('sending', $.proxy(this.onBeforeSend, this));
          _dz.on('success', $.proxy(this.onSuccess, this));
          _dz.on('removedfile', $.proxy(this.onRemove, this));
          _dz.on('error', $.proxy(this.onError, this));
          Voltron.dispatch('upload:initialized', { upload: this, dropzone: _dz, element: this.getInput().get(0) });
        }
      },

      // Add the authenticity token to the request
      onBeforeSend: function(file, xhr, data){
        data.append('authenticity_token', Voltron.getAuthToken());

        Voltron.dispatch('upload:sending', { upload: this, form: this.getForm().get(0), file: file, xhr: xhr, data: data, element: this.getInput().get(0) });

        // If single file upload dropzone, remove anything that may have been previously uploaded,
        // change any commit inputs to remove inputs, so the file will be deleted when submitted
        if(!this.isMultiple()){
          $(file.previewElement).closest('.dropzone').find('.dz-preview').each($.proxy(function(index, el){
            var id = $(el).data('id');

            if(id) this.addRemoval(id);
            $(el).remove();
          }, this));
        }
      },

      // Once a file is uploaded, add a hidden input that flags the file to be committed once the form is submitted
      onSuccess: function(file, data){
        for(var i=0; i<data.uploads.length; i++){
          $(file.previewElement).attr('data-id', data.uploads[i].id);
          this.addCache(data.uploads[i].id);
        }

        // Dispatch upload complete event. This can be picked up by other modules to perform additional actions
        // i.e. - The Voltron Crop module will observe this to set the crop image once uploaded
        Voltron.dispatch('upload:complete', { upload: this, file: file, data: data, element: this.getInput().get(0) });
      },

      // When a file is removed, eliminate any hidden inputs that may have flagged the file for "committing"
      // and add the hidden input that flags the file in question for removal
      onRemove: function(file){
        var f, id = $(file.previewElement).data('id');

        // This line accounts for files that were uploaded, but removed before the form was submitted
        // Once the form is submitted the file exists in the data-files attribute
        this.addRemoval(id);

        // Dispatch the upload removed event, can be observed in any other Voltron module
        // by defining an onUploadRemoved event
        Voltron.dispatch('upload:removed', { upload: this, file: file, element: this.getInput().get(0) });
      },

      onError: function(file, data){
        $(file.previewElement).find('.dz-error-message').text(typeof data == 'string' ? data : data.error.join('<br />'));
        Voltron.dispatch('upload:error', { upload: this, file: file, data: [data].flatten(), element: this.getInput().get(0) })
      }
    };
  };

  return {
    initialize: function(){
      $.each($('input[type="file"]:visible'), this.addUpload);
    },

    addUpload: function(){
      var upload = new Upload(this);
      upload.initialize();
    },

    getFileBlob: function(url, cb){
      var xhr = new XMLHttpRequest();
      xhr.open('GET', url);
      xhr.responseType = 'blob';
      xhr.addEventListener('load', function(){
        cb(xhr.response);
      });
      xhr.send();
    },

    blobToFile: function(blob, name){
      blob.lastModifiedDate = new Date();
      blob.name = name;
      blob.status = 'added';
      blob.accepted = true;
      return blob;
    },

    getFileObject: function(file, name, cb){
      this.getFileBlob(file.url, function(blob){
        cb(Voltron('Upload/blobToFile', blob, file.name), name);
      });
    }
  };
}, true);
