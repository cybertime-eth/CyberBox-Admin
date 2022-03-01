class CreateTraitValues < ActiveRecord::Migration[7.0]
  def change
    create_table :trait_values do |t|
      t.string :trait_id
      t.string :address
      t.string :nft_symbol
      t.string :trait_type
      t.string :trait_value
      t.integer :use_count
      t.timestamps
    end
  end
end
