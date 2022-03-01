ActiveAdmin.register TraitValue do
    menu label: "Collections"
    menu priority: 3
    config.per_page = 50

    index do
        column :id
        column :"Contract" do |trait_value|
            trait_value.nft_symbol
        end
        column :"traitType" do |trait_value|
            trait_value.trait_type
        end
        column :"traitValue" do |trait_value|
            trait_value.trait_value
        end
        column :"use_count" do |trait_value|
            trait_value.use_count
        end
   
    end

    filter :id_eq
    filter :trait_type, as: :string
    filter :nft_symbol, as: :string
end