class AddColumnCategoryToShops < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :category, :string
  end
end
