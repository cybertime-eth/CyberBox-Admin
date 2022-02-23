class CreateErrorImageItems < ActiveRecord::Migration[7.0]
  def change
    create_table :error_image_items do |t|
      t.belongs_to "contract_info"
      t.string "contract_name"
      t.timestamps
    end
  end
end
