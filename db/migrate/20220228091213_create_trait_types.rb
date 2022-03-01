class CreateTraitTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :trait_types do |t|
      t.string :trait_type_id
      t.string :address
      t.string :nft_symbol
      t.string :trait_type
      t.integer :trait_index
      t.timestamps
    end
  end
end
