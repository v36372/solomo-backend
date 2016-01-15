class AddAuthenticationTokenToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string   "authentication_token",        limit: 191
    end
  end
end
