module Voltron
  module Upload
    module Parameters

      def commit!(uploader)
        # Get all uploads that can be committed based on what uploaders we have mounted in the model
        commits = uploader.committable_uploads(@parameters[uploader.resource_name])

        # Compile a list of the commit parameters we'll extract data from, these keys will be deleted from the params hash
        commit_keys = commits.keys.map { |c| "commit_#{c}" }

        # Merge in our files to commit
        @parameters[uploader.resource_name] = @parameters[uploader.resource_name].merge(commits)

        # Get rid of all the `commit_*` parameters, no longer needed
        @parameters[uploader.resource_name].reject! { |k| commit_keys.include?(k) }
      end

    end
  end
end
