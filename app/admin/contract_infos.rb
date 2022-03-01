ActiveAdmin.register ContractInfo do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :contract_info_id, :contract, :contract_id, :price, :seller, :owner, :contract_address, :nftSymbol, :market_status, :dna, :name, :description, :attributeString, :image, :tag_attribute_count
  #
  # or
  #
  # permit_params do
  #   permitted = [:contract_info_id, :contract, :contract_id, :price, :seller, :owner, :contract_address, :nftSymbol, :market_status, :dna, :name, :description, :attributeString, :image, :tag_attribute_count]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  menu label: "Collections"
  menu priority: 2
  config.per_page = 50

  index do
    column :id
    column :"Name" do |contract_info|
      contract_info.name
    end
    column :"contract" do |contract_info|
      contract_info.contract
    end
    column :"contract id" do |contract_info|
      contract_info.contract_id
    end
    column :"rating_index" do |contract_info|
      contract_info.rating_index
    end
    actions
  end

  controller do
  end

  filter :id_eq
  filter :name, as: :string
  filter :contract, as: :string
end
