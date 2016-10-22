module Voltron
  module Upload
    module ActionController
      module Parameters

        cattr_accessor :uploader

        def permit(*filters)
          filters += uploader.allowed_params if uploader

          super *filters
        end

        def add_commit_params_for(uploader)
          @parameters[uploader.resource.name.singularize.underscore] ||= {}

          uploader.columns.keys.each do |c|
            if @parameters[uploader.resource.name.singularize.underscore]["commit_#{c}"]
              @parameters[uploader.resource.name.singularize.underscore].merge!(commits_from(@parameters[uploader.resource.name.singularize.underscore]["commit_#{c}"]))
            end
          end
        end

        def commits_from(commits)
          ::Voltron::Temp.to_param_hash(commits)
        end

      end
    end
  end
end
