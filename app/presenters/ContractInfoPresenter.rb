class ContactPresenter < BasePresenter
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
        dna: dna,
        name: name,
        description: description,
        attributes: attributes,
        image: image,
        tag_attribute_count: tag_attribute_count
    }
end