class AddPromotionsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :promotion_type, :string
    add_column :posts, :promotion_value, :text
  end
end
