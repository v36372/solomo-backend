class AddVerifyCodesToStore < ActiveRecord::Migration
  def change
    add_column :stores, :verify_code, :string
  end
end
