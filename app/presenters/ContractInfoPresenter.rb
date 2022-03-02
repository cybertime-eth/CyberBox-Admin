class ContractInfoPresenter < BasePresenter
    def to_h
        {
            id: id,
            contract_info_id: contract_info_id,
            contract: contract,
            contract_id: contract_id,
            price: price,
            seller: seller,
            owner: owner,
            contract_address: contract_address,
            nftSymbol: nftSymbol,
            market_status: market_status,
            name: name,
            rating_index: rating_index
        }
    end
end