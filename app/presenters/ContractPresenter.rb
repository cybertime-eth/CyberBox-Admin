# frozen_string_literal: true

class ContactPresenter < BasePresenter
    def to_h
    {
        id: id,
        contract_id: contract_id,
        title: title,
        nftName: nftName,
        nftSymbol: nftSymbol,
        nftAddress: nftAddress,
        erc20Name: erc20Name,
        erc20Symbol: erc20Symbol,
        erc20Address: erc20Address,
        marketPlaceAddress: marketPlaceAddress,
        marketFee: marketFee,
        marketPlaceFeeAddress: marketPlaceFeeAddress,
        createrFee: createrFee,
        tokenCreaterAddress: tokenCreaterAddress,
        producerFee: producerFee,
        tokenProducerAddress: tokenProducerAddress,
        ownerCount: ownerCount,
        mint_count: mint_count,
        bid_count: bid_count,
        list_count: list_count,
        sell_count: sell_count,
        sell_max_price: sell_max_price,
        sell_min_price: sell_min_price,
        sell_total_price: sell_total_price,
        dna_count: dna_count,
        traitTypesCount: traitTypesCount
    }
end