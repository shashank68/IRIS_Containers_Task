class AddColumnAddressToShops < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :address, :text
  end
end
