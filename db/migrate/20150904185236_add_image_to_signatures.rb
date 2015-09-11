class AddImageToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :image, :string
  end
end
