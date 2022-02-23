ActiveAdmin.register ErrorImageItem do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :contract_info_id, :contract_name
  #
  # or
  #
  # permit_params do
  #   permitted = [:contract_info_id, :contract_name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  menu label: "Collections"
  menu priority: 3
  config.per_page = 50

  member_action :fetch, :method=>:get do
  end

  member_action :fetch_all, :method=>:get do
  end

  index do
    column :id
    column :"contract_name" do |item|
      item.contract_name
    end
    column() do |item|
      link_to 'Fetch IPFS', fetch_admin_error_image_item_path(item), :data => {:confirm => 'Are you sure? It will take more minutes.'}
    end
    column() do |item|
      link_to 'Fetch ALL ERROR', fetch_all_admin_error_image_item_path(item), :data => {:confirm => 'Are you sure? It will take more minutes.'}
    end
  end

  controller do
    def fetch
      @item = ErrorImageItem.find(params[:id])
      helpers.fetchIPFSImage(@item.contract_name)
      redirect_to admin_error_image_items_path, notice: "Fetching information started"
    end

    def fetch_all
      helpers.fetchAllErrorImages()
      redirect_to admin_error_image_items_path, notice: "Fetching information started"
    end
  end

  filter :id_eq
end
