module Voltron
  class Temp < ActiveRecord::Base

    mount_uploader :file, Voltron::TempUploader

    def self.to_param_hash(*commit_ids)
      params = {}
      commit_ids.flatten.each do |id|
        if tmp = find_by(uuid: id)
          if tmp.multiple?
            params[tmp.column] ||= []
            params[tmp.column] << File.open(tmp.file.path)
          else
            params[tmp.column] = File.open(tmp.file.path)
          end
        end
      end
      params
    end

    def self.remove_temps(remove_files)
      (remove_files || {}).map do |column,removes|
        destroyed = where(uuid: removes).destroy_all
        { "remove_#{column}".to_sym => removes - destroyed.map(&:uuid) }
      end.reduce(Hash.new, :merge)
    end

  end
end
