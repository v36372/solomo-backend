class AddPostBoostToPostView < ActiveRecord::Migration
  def change
    add_column :post_views, :post_boost_id, :integer
  end
end
