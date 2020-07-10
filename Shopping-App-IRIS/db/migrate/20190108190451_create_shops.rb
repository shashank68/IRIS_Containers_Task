class CreateShops < ActiveRecord::Migration[5.2]
  def change
    create_table :shops do |t|
      t.string :title
      t.text :description
      t.integer :excost

      t.timestamps
    end
  end
end
