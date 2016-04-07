class AddTimestampToStores < ActiveRecord::Migration
  def change
    add_column :stores, :created_at, :datetime
    add_column :stores, :updated_at, :datetime
  end
end
