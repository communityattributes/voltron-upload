//= require dropzone
//= require voltron

Dropzone.autoDiscover = false;

Voltron.addModule('Upload', function(){
  return {
    initialize: function(){
      $('[data-upload]').each(this.addUpload);
    },

    getModel: function(input){
      return $(input).attr('name').match(/^[A-Z_0-9]+/i)[0];
    },

    getMethod: function(input){
      return $(input).attr('name').match(/^[A-Z_0-9]+\[([A-Z_0-9]+)\]/i)[1];
    },

    getParamName: function(input, name, multiple){
      return this.getModel(input) + '[' + name + '_' + this.getMethod(input) + ']' + (multiple ? '[]' : '');
    },

    addUpload: function(){
      var input = $(this);
      var form = $(this).closest('form');

      if(!input.closest('.fallback').length) input.wrap($('<div />', { class: 'fallback' }));
      if(!input.closest('.dropzone').length) input.closest('.fallback').wrap($('<div />', { class: 'dropzone' }));

      var dz = new Dropzone(input.closest('.dropzone').get(0), {
        url: input.data('upload'),
        paramName: input.attr('name'),
        parallelUploads: 1,
        addRemoveLinks: true
      });

      // Add the input and form elements to the dropzone instance so we can access it later
      dz.input = input.get(0);
      dz.form = form.get(0);
      input.data('dropzone', dz);

      $.each(input.data('commit'), function(index, id){
        form.prepend($('<input />', { type: 'hidden', name: Voltron.getModule('Upload').getParamName(dz.input, 'commit', true), value: id }));
      });

      // If set to preserve file uploads, iterate through each uploaded file associated with
      // the model and add to the file upload box upon initialization
      $.each(input.data('files'), function(index, upload){
        //console.log(upload);
        Voltron.getModule('Upload').getFileObject(upload, upload.id, function(fileObject, id){
          dz.files.push(fileObject);
          dz.options.addedfile.call(dz, fileObject);
          $(fileObject.previewElement).attr('data-id', id);
          dz._enqueueThumbnail(fileObject);
          dz.options.complete.call(dz, fileObject);
          dz._updateMaxFilesReachedClass();
        });
      });

      dz.on('sending', Voltron.getModule('Upload').onBeforeSend);
      dz.on('success', Voltron.getModule('Upload').onSuccess);
      dz.on('removedfile', Voltron.getModule('Upload').onRemove);
      dz.on('addedfile', Voltron.getModule('Upload').onAdd);
      dz.on('error', Voltron.getModule('Upload').onError);
    },

    onBeforeSend: function(file, xhr, data){
      // Add the authenticity token to the request
      data.append('authenticity_token', Voltron.getAuthToken());
    },

    onSuccess: function(file, data){
      var form = $(this.form);
      var input = this.input;
      $.each(data.uploads, function(index, id){
        $(file.previewElement).attr('data-id', id);
        form.prepend($('<input />', { type: 'hidden', name: Voltron.getModule('Upload').getParamName(input, 'commit', true), value: id }));
      });
    },

    onRemove: function(file){
      var id = $(file.previewElement).data('id');
      var commitName = Voltron.getModule('Upload').getParamName(this.input, 'commit', true);
      $(this.form).find('input[name="' + commitName + '"][value="' + id + '"]').remove();
      $(this.form).prepend($('<input />', { type: 'hidden', name: Voltron.getModule('Upload').getParamName(this.input, 'remove', true), value: id }));
    },

    onAdd: function(file){
      if(!this.input.multiple){
        $(file.previewElement).closest('.dropzone').find('.dz-preview').each(function(){
          if($(this).get(0) != $(file.previewElement).get(0)){
            $(this).remove();
          }
        });
      }
    },

    onError: function(file, response){
      $(file.previewElement).find('.dz-error-message').text(response.messages.join('<br />'));
    },

    getFileBlob: function(url, cb){
      var xhr = new XMLHttpRequest();
      xhr.open("GET", url);
      xhr.responseType = "blob";
      xhr.addEventListener('load', function(){
        cb(xhr.response);
      });
      xhr.send();
    },

    blobToFile: function(blob, name){
      blob.lastModifiedDate = new Date();
      blob.name = name;
      blob.status = "added";
      blob.accepted = true;
      return blob;
    },

    getFileObject: function(file, name, cb){
      this.getFileBlob(file.url, function(blob){
        cb(Voltron.getModule('Upload').blobToFile(blob, file.name), name);
      });
    }
  };
}, true);
