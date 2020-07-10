class AddColumnShopidToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :shopid, :integer
  end
end
