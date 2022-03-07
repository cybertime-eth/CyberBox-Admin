class ChangeRatingFieldsToContractInfos < ActiveRecord::Migration[7.0]
  def change
    change_column :contract_infos, :rating_value, :double

  end
end
