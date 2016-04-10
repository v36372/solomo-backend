class AddIsAutoToPostTags < ActiveRecord::Migration
  def change
    add_column :post_tags, :is_auto, :boolean, default: false
  end
end
