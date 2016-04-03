class CreateNotification < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :notification_type
      t.boolean :read, default: false
      t.text :message
      t.integer :notifiable_id
      t.string :notifiable_type
      t.integer :notifier_id
      t.integer :receiver_id
      t.datetime :updated_at
      t.datetime :created_at
    end
  end
end
