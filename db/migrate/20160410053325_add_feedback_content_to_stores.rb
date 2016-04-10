class AddFeedbackContentToStores < ActiveRecord::Migration
  def change
    add_column :stores, :feedback_content, :text
  end
end
