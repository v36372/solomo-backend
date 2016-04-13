class AddRenderedHashToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :rendered_hash, :text
  end
end
