module Api
    module V1
      class ContractInfosController < Api::V1::BaseController
        
        def getNfts
          nft_symbol = params["nft"]
          from = params["from"]
          to = params["to"]
          nfts = ContractInfo.where(contract: nft_symbol).where("contract_id >= #{from} and contract_id <= #{to}")
          render_presenters nfts
        end


        def getCollections
          nft_ids = params["contract_ids"]
          nfts = ContractInfo.where(contract_info_id:nft_ids)
          render_presenters nfts
        end
      end
    end
end