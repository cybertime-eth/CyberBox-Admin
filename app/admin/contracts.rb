ActiveAdmin.register Contract do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :contract_id, :title, :nftName, :nftSymbol, :nftAddress, :erc20Name, :erc20Symbol, :erc20Address, :marketPlaceAddress, :marketFee, :marketPlaceFeeAddress, :createrFee, :tokenCreaterAddress, :producerFee, :tokenProducerAddress, :ownerCount, :mint_count, :bid_count, :list_count, :sell_count, :sell_max_price, :sell_min_price, :sell_total_price, :dna_count, :traitTypesCount
  #
  # or
  #
  # permit_params do
  #   permitted = [:contract_id, :title, :nftName, :nftSymbol, :nftAddress, :erc20Name, :erc20Symbol, :erc20Address, :marketPlaceAddress, :marketFee, :marketPlaceFeeAddress, :createrFee, :tokenCreaterAddress, :producerFee, :tokenProducerAddress, :ownerCount, :mint_count, :bid_count, :list_count, :sell_count, :sell_max_price, :sell_min_price, :sell_total_price, :dna_count, :traitTypesCount]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  menu label: "Collections"
  menu priority: 1
  config.per_page = 50

  member_action :fetch, :method=>:get do
  end

  member_action :fetch_all, :method=>:get do
  end

  member_action :fetch_traits, :method=>:get do
  end

  index do
    column :id
    column :"nftName" do |contract|
      contract.nftName
    end
    column :"nftSymbol" do |contract|
      contract.nftSymbol
    end
    column :"mint_count" do |contract|
      contract.mint_count
    end
    column() do |contract|
      link_to 'Fetch NFT', fetch_admin_contract_path(contract), :data => {:confirm => 'Are you sure? It will take more minutes.'}
    end
    column() do |contract|
      link_to 'Fetch ALL NFT', fetch_all_admin_contract_path(contract), :data => {:confirm => 'Are you sure? It will take more minutes.'}
    end
    column() do |contract|
      link_to 'Fetch Traits', fetch_traits_admin_contract_path(contract), :data => {:confirm => 'Are you sure? It will take more minutes.'}
    end

    actions
  end

  controller do
    def fetch
      @contract = Contract.find(params[:id])
      helpers.fetchContractDetail(@contract.nftAddress)
      redirect_to admin_contracts_path, notice: "Fetching information started"
    end

    def fetch_all
      helpers.fetchAllContractDetail()
      redirect_to admin_contracts_path, notice: "Fetching information started"
    end

    def fetch_traits
      @contract = Contract.find(params[:id])
      helpers.fetchAllTraitValues(@contract.nftAddress)
      redirect_to admin_contracts_path, notice: "Fetching information started"
    end
  end

  filter :id_eq
  filter :nftName, as: :string
  filter :nftSymbol, as: :string
end

