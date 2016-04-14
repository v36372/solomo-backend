class AddPriceToUserFeed < ActiveRecord::Migration
  def change
    add_column :user_feeds, :price, :integer
  end
end
