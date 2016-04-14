class AddPostBoostToUserFeed < ActiveRecord::Migration
  def change
    add_column :user_feeds, :post_boost_id, :integer
  end
end
