class User < ApplicationRecord

	mount_uploader :avatar, AvatarUploader

	mount_uploaders :images, ImageUploader

  serialize :images, JSON

	validates_presence_of :name

end
