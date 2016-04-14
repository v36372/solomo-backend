class AddPriceToPostBoosts < ActiveRecord::Migration
  def change
    add_column :post_boosts, :price, :integer
  end
end
