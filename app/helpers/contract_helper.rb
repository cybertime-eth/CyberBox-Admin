module ContractHelper
    GRAPHQL_ENDPOINT = "https://api.thegraph.com/subgraphs/name/itdev-1210/celo-add-chin-chilla"
    GRAPHQL_TOKEN = "3f88570f315c4e18886a286382acfa72"
    
    def fetchAllContractDetail
        logger.info("---------fetchAllContractDetail started -------")
        contracts_data = fetchTheGraphAllContracts()
        contracts_data.each do |contract_data|
            saveContractModel(contract_data)
        end

        logger.info("---------fetchAllContractDetail completed -------")
    end

    def fetchContractDetail(nftAddress)
        logger.info("---------fetchContractDetail #{nftAddress} -------")
        contract_data = fetchTheGraphContract(nftAddress)
        saveContractModel(contract_data)
        all_mint_count =  contract_data.mint_count
        nftSymbil = contract_data.nft_symbol
        start_index = 0
        per_page_count = 50
        while start_index < all_mint_count
            contractInfo_datas = fetchTheGraphContractDetail(start_index, start_index + per_page_count, nftSymbil)
            contractInfo_datas.each do |contractInfo_data|
                saveContractInfoModel(contractInfo_data)
            end
            start_index = start_index + per_page_count
        end
        logger.info("---------fetchContractDetail completed -------")
    end

    def fetchIPFS
        errorLogs = ErrorImageItem.all.first(10)
        errorLogs.each do |error_item|
            contract_name = error_item.contract_name
            fetchIPFSImage(contract_name)
        end
    end

    def fetchIPFSImage(contract_name)
        contractInfo = ContractInfo.find_by(contract_info_id:contract_name)
        if contractInfo.present?
            errorLogs = ErrorImageItem.find_by(contract_name:contractInfo.contract_info_id)
            if errorLogs.present?
                errorLogs.destroy
            end
            makeThumbnail(contractInfo)
        end
    end

    def fetchAllErrorImages
        allErrors = ErrorImageItem.all
        allErrors.each do |error_item|
            contract_name = error_item.contract_name
            if contract_name.include? "nomstronaut"
            else
                sleep(2)
            end
            fetchIPFSImage(contract_name)
        end
        logger.info("---------fetchAllErrorImages completed -------")
    end


    def saveContractModel(contractData)
        contract_address = contractData.id
        @contract = Contract.where(contract_id: contract_address).first
        if @contract.blank?
            @contract = Contract.new
        end
        @contract.contract_id = contractData.id
            @contract.title = contractData.title
            @contract.nftName = contractData.nft_name
            @contract.nftSymbol = contractData.nft_symbol
            @contract.nftAddress = contract_address
            @contract.erc20Name = contractData.erc20_name
            @contract.erc20Symbol = contractData.erc20_symbol
            @contract.erc20Address = contractData.erc20_address
            @contract.marketPlaceAddress = contractData.market_place_address
            @contract.marketFee = contractData.market_fee
            @contract.marketPlaceFeeAddress = contractData.market_place_fee_address
            @contract.createrFee = contractData.creater_fee
            @contract.tokenCreaterAddress = contractData.token_creater_address
            @contract.producerFee = contractData.producer_fee
            @contract.tokenProducerAddress = contractData.token_producer_address
            @contract.ownerCount = contractData.owner_count
            @contract.mint_count = contractData.mint_count
            @contract.bid_count = contractData.bid_count
            @contract.list_count = contractData.list_count
            @contract.sell_count = contractData.sell_count
            @contract.sell_max_price = contractData.sell_max_price
            @contract.sell_min_price = contractData.sell_min_price
            @contract.sell_total_price = contractData.sell_total_price
            @contract.traitTypesCount = contractData.trait_types_count
            @contract.save!
    end

    def saveContractInfoModel(contractInfosData)
        puts "# saveContractInfoModel #{contractInfosData.id}}"
        contract_info_id = contractInfosData.id
        @contractInfo = ContractInfo.where(contract_info_id: contract_info_id).first
        if @contractInfo.blank?
            @contractInfo = ContractInfo.new
            @contractInfo.contract_info_id = contractInfosData.id
            @contractInfo.contract =  contractInfosData.contract
            @contractInfo.contract_id =  contractInfosData.contract_id
            @contractInfo.price =  contractInfosData.price
            @contractInfo.seller =  contractInfosData.seller
            @contractInfo.owner =  contractInfosData.owner
            @contractInfo.contract_address =  contractInfosData.contract_address
            @contractInfo.nftSymbol =  contractInfosData.contract
            @contractInfo.market_status =  contractInfosData.market_status
            @contractInfo.dna =  contractInfosData.dna
            @contractInfo.name =  contractInfosData.name
            @contractInfo.description =  contractInfosData.description
            @contractInfo.attributeString =  contractInfosData.attributes
            @contractInfo.image =  contractInfosData.image
            @contractInfo.tag_attribute_count =  contractInfosData.tag_attribute_count
            @contractInfo.save!
        end
        
        makeThumbnail(@contractInfo)
    end
    # //"ipfs://QmNcjPTYFFsDosWAXFzefUX9y7hsVjXDPRr2hw5MhPdGoo/245.png"
    # https://ipfs.io/ipfs/QmNcjPTYFFsDosWAXFzefUX9y7hsVjXDPRr2hw5MhPdGoo/123.png
    def makeThumbnail(contract_info_obj)
        imagePath = "#{Rails.root}/public/#{contract_info_obj.nftSymbol}/#{contract_info_obj.contract_id}.png"
        if File.exist?(imagePath) == false
            FileUtils.mkdir_p "#{Rails.root}/public/#{contract_info_obj.nftSymbol}/"
            if contract_info_obj.image.present?
                begin
                    puts "#{contract_info_obj.image}"
                    imageUrl = contract_info_obj.image
                    if imageUrl.include? "ipfs://"
                        imageUrl["ipfs://"]= "https://ipfs.io/ipfs/"
                    end
                    MiniMagick.configure do |config|
                        config.timeout = 10
                    end
                    logger.info("//////// start loading image ///////")
                    logger.info(imageUrl)
                    image = MiniMagick::Image.open(imageUrl)
                    logger.info("//////// complete loading image ///////")
                    
                    imageFormat = File.extname(URI.parse(imageUrl).path)
                    if imageFormat.include? "."
                        imageFormat["."] = ""
                    end

                    imageDimension_width = image.dimensions[0]

                    targetFileName = "#{Rails.root}/public/#{contract_info_obj.nftSymbol}/#{contract_info_obj.contract_id}.png"
                    if imageFormat == "gif"
                        targetFileName = "#{Rails.root}/public/#{contract_info_obj.nftSymbol}/#{contract_info_obj.contract_id}.gif"
                        image.write(targetFileName)
                    elsif imageDimension_width < 280
                        image.write(targetFileName)
                    else
                        image.resize "280x280"
                        image.format imageFormat
                        image.write(targetFileName)
                    end
                    File.chmod(0777, targetFileName)
                rescue => e
                    puts "# makeThumbnail error"
                    @errorItem = ErrorImageItem.create(contract_info_id: contract_info_obj.id, contract_name: contract_info_obj.contract_info_id)
                end
            end
        end
    end

    def fetchTheGraphContract(nftAddress)
        puts "# fetchTheGraphContract #{nftAddress}}}"
        client = Graphlient::Client.new(GRAPHQL_ENDPOINT,
                headers: {
                    'Authorization' => "Bearer #{GRAPHQL_TOKEN}"
                },
                http_options: {
                    read_timeout: 20,
                    write_timeout: 30
                }
        )
        response = client.query do
            query do
                contract(id:"#{nftAddress}") do
                    id
                    title
                    nftName
                    nftSymbol
                    nftAddress
                    erc20Name
                    erc20Symbol
                    erc20Address
                    marketPlaceAddress
                    marketFee
                    marketPlaceFeeAddress
                    createrFee
                    tokenCreaterAddress
                    producerFee
                    tokenProducerAddress
                    ownerCount
                    mint_count
                    bid_count
                    list_count
                    sell_count
                    sell_max_price
                    sell_min_price
                    sell_total_price
                    traitTypesCount
                end
            end
        end
        response.data.contract
    end

    def fetchTheGraphAllContracts
        puts "# fetchTheGraphAllContracts}"
        client = Graphlient::Client.new(GRAPHQL_ENDPOINT,
                headers: {
                    'Authorization' => "Bearer #{GRAPHQL_TOKEN}"
                },
                http_options: {
                    read_timeout: 20,
                    write_timeout: 30
                }
        )
        response = client.query do
            query do
                contracts(where: {mint_count_not: 0}) do
                    id
                    title
                    nftName
                    nftSymbol
                    nftAddress
                    erc20Name
                    erc20Symbol
                    erc20Address
                    marketPlaceAddress
                    marketFee
                    marketPlaceFeeAddress
                    createrFee
                    tokenCreaterAddress
                    producerFee
                    tokenProducerAddress
                    ownerCount
                    mint_count
                    bid_count
                    list_count
                    sell_count
                    sell_max_price
                    sell_min_price
                    sell_total_price
                    traitTypesCount
                end
            end
        end
        response.data.contracts
    end

    def fetchTheGraphContractDetail(from, count, nftSymbol)
        puts "# fetchTheGraphContractDetail #{from} #{count} #{nftSymbol}}"
        client = Graphlient::Client.new(GRAPHQL_ENDPOINT,
                headers: {
                    'Authorization' => "Bearer #{GRAPHQL_TOKEN}"
                },
                http_options: {
                    read_timeout: 20,
                    write_timeout: 30
                }
        )
        response = client.query do
            query do
                contractInfos(where:{contract:"#{nftSymbol}", contract_id_lt:count + 1, contract_id_gt:from - 1}) do
                    id
                    contract
                    contract_id
                    price
                    seller
                    owner
                    contract_address
                    nftSymbol
                    market_status
                    dna
                    name
                    description
                    attributes
                    image
                    tag_attribute_count
                end
            end
        end
        response.data.contract_infos
    end

end
