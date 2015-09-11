class Signature < ActiveRecord::Base
 	belongs_to :document
 	mount_uploader :image, ImageUploader
end