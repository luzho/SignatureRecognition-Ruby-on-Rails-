class Document < ActiveRecord::Base
  	has_many :signatures
  	mount_uploader :image, ImageUploader
end
