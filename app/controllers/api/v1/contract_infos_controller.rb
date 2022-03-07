module Api
    module V1
      class ContractInfosController < Api::V1::BaseController
        skip_before_action :verify_authenticity_token
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

        def getRarityNfts
          nft_symbol = params["symbol"]
          direction = params["direction"]
          start_id = params["from"].to_i
          count = params["count"].to_i
          
          if direction == "desc"
            contracts = ContractInfo.where(contract: nft_symbol).order(rating_index: :desc).offset(start_id).limit(count)
            render_presenters contracts, ContractInfo
          else
            contracts = ContractInfo.where(contract: nft_symbol).order(:rating_index).offset(start_id).limit(count)
            render_presenters contracts, ContractInfo
          end
        end
      end
    end
end