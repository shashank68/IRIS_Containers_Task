class AddColumnContactdetailsToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :contactdetails, :text
  end
end
