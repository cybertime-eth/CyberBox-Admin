class AddRatingFieldsToContractInfos < ActiveRecord::Migration[7.0]
  def change
    add_column :contract_infos, :rating_value, :integer
    add_column :contract_infos, :rating_index, :integer
  end
end
