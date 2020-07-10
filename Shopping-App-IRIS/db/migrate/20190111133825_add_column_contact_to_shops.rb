class AddColumnContactToShops < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :contact, :string
  end
end
