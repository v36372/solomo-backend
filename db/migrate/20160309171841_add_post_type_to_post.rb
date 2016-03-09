class AddPostTypeToPost < ActiveRecord::Migration
  def change
    add_column :posts, :post_type, :string
    add_column :posts, :crawl_user_name, :text
    add_column :posts, :crawl_user_avatar, :text
    add_column :posts, :crawl_user_email, :string
  end
end
