class User < ApplicationRecord

	mount_uploader :avatar, AvatarUploader

	mount_uploaders :images, ImageUploader

	validates_presence_of :name

end
