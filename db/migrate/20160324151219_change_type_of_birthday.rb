class ChangeTypeOfBirthday < ActiveRecord::Migration
  def change
    change_column :users, :birthday, :datetime
  end
end
