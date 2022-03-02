class ContractInfoPresenter < BasePresenter
    def to_h
        {
            id: id,
            contract_info_id: contract_info_id,
            contract: contract,
            contract_id: contract_id,
            nftSymbol: nftSymbol,
            name: name,
            rating_index: rating_index
        }
    end
end