module ContractHelper
    GRAPHQL_ENDPOINT = "https://api.thegraph.com/subgraphs/name/itdev-1210/nom-registrar-three"
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
            fetchIPFSImage(contract_name)
        end
        logger.info("---------fetchAllErrorImages completed -------")
    end

    def fetchAllTraitValues(address)
        from = 0
        fetch_count = 50
        page_count = 50

        while fetch_count > 0
            fetch_datas = fetchTraitTypes(from, page_count, address)
            fetch_count = fetch_datas.count
            from = from + fetch_count
            fetch_datas.each do |data|
                fetch_id = data.id
                @traitType = TraitType.where(trait_type_id: fetch_id).first
                if @traitType.blank?
                    @traitType = TraitType.new
                end
                @traitType.trait_type_id = data.id
                @traitType.address = address
                @traitType.nft_symbol = data.nft_symbol
                @traitType.trait_type = data.trait_type
                @traitType.trait_index = data.trait_index
                @traitType.save!
            end
        end


        from = 0
        fetch_count = 50
        page_count = 50
        while fetch_count > 0
            fetch_datas = fetchTraitValues(from, page_count, address)
            fetch_count = fetch_datas.count
            from = from + fetch_count
            fetch_datas.each do |data|
                fetch_id = data.id
                @trait = TraitValue.where(trait_id: fetch_id).first
                if @trait.blank?
                    @trait = TraitValue.new
                end
                @trait.trait_id = data.id
                @trait.address = address
                @trait.nft_symbol = data.nft_symbol
                @trait.trait_type = data.trait_type
                @trait.trait_value = data.trait_value
                @trait.use_count = data.use_count
                @trait.save!
            end
        end
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
        end
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
        @contractInfo.tag_element0 = contractInfosData.tag_element0
        @contractInfo.tag_element1 = contractInfosData.tag_element1
        @contractInfo.tag_element2 = contractInfosData.tag_element2
        @contractInfo.tag_element3 = contractInfosData.tag_element3
        @contractInfo.tag_element4 = contractInfosData.tag_element4
        @contractInfo.tag_element5 = contractInfosData.tag_element5
        @contractInfo.tag_element6 = contractInfosData.tag_element6
        @contractInfo.tag_element7 = contractInfosData.tag_element7
        @contractInfo.tag_element8 = contractInfosData.tag_element8
        @contractInfo.tag_element9 = contractInfosData.tag_element9
        @contractInfo.tag_element10 = contractInfosData.tag_element10
        @contractInfo.tag_element11 = contractInfosData.tag_element11
        @contractInfo.tag_element12 = contractInfosData.tag_element12
        @contractInfo.tag_element13 = contractInfosData.tag_element13
        @contractInfo.tag_element14= contractInfosData.tag_element14
        @contractInfo.tag_element15= contractInfosData.tag_element15
        @contractInfo.save!
        
        if @contractInfo.nftSymbol != "christmaspunk"
            makeThumbnail(@contractInfo)
        end
    end
    # //"ipfs://QmNcjPTYFFsDosWAXFzefUX9y7hsVjXDPRr2hw5MhPdGoo/245.png"
    # https://ipfs.io/ipfs/QmNcjPTYFFsDosWAXFzefUX9y7hsVjXDPRr2hw5MhPdGoo/123.png
    def makeThumbnail(contract_info_obj)
        if contract_info_obj.nftSymbol == "nomdom"
            puts "#{contract_info_obj.contract_id}"
            imageName = contract_info_obj.image
            imagePath = "#{Rails.root}/public/#{contract_info_obj.nftSymbol}/#{imageName}.png"
            if File.exist?(imagePath) == false
              drawTextToNomImage(contract_info_obj.name, imageName)
            end
            return
        end
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
                    # sleep(30)
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
                    tag_element0
                    tag_element1
                    tag_element2
                    tag_element3
                    tag_element4
                    tag_element5
                    tag_element6
                    tag_element7
                    tag_element8
                    tag_element9
                    tag_element10
                    tag_element11
                    tag_element12
                    tag_element13
                    tag_element14
                    tag_element15
                end
            end
        end
        response.data.contract_infos
    end

    def fetchTraitTypes(from, count, address)
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
                traitTypes(where:{address:"#{address}"}, skip:from, first:count) do
                    id
                    address
                    nftSymbol
                    traitType
                    traitIndex
                end
            end
        end
        response.data.trait_types
    end

    def fetchTraitValues(from, count, address)
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
                traitValues(where:{address:"#{address}"}, skip:from, first:count) do
                    id
                    address
                    nftSymbol
                    traitType
                    traitValue
                    useCount
                end
            end
        end
        response.data.trait_values
    end


    def makeRating(contract_address)
        if contract_address == "0x07b6c9d6bb32655a70d97a38a9274da349a1efaf" #####cpunkneon
            contractInfos = ContractInfo.where(contract_address: contract_address)
            contractInfos.each do |data|
                data.rating_index = data.tag_element0.to_i
                data.save!
            end
        else
            contractInfos = ContractInfo.where(contract_address: contract_address)
            totalCount = contractInfos.count
            contractInfos.each do |data|
                ratingSum = calcRatingSum(data, totalCount)
                data.rating_value = ratingSum
                data.save!
            end
            contractInfos = ContractInfo.where(contract_address: contract_address).order(:rating_value)
            rating_index = totalCount
            contractInfos.each do |data|
                data.rating_index = rating_index
                data.save!
                rating_index = rating_index - 1
            end
        end
    end

    def calcRatingSum(contractInfo, totalCount)
        sql = "select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
        sql = sql + "type.trait_index = 0 where trait_values.trait_value = '#{contractInfo.tag_element0}' and trait_values.address = '#{contractInfo.contract_address}'"
        if contractInfo.tag_element1.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 1 where trait_values.trait_value = '#{contractInfo.tag_element1}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element2.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 2 where trait_values.trait_value = '#{contractInfo.tag_element2}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element3.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 3 where trait_values.trait_value = '#{contractInfo.tag_element3}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element4.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 4 where trait_values.trait_value = '#{contractInfo.tag_element4}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element5.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 5 where trait_values.trait_value = '#{contractInfo.tag_element5}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element6.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 6 where trait_values.trait_value = '#{contractInfo.tag_element6}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element7.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 7 where trait_values.trait_value = '#{contractInfo.tag_element7}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element8.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 8 where trait_values.trait_value = '#{contractInfo.tag_element8}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element9.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 9 where trait_values.trait_value = '#{contractInfo.tag_element9}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element10.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 10 where trait_values.trait_value = '#{contractInfo.tag_element10}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element11.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 11 where trait_values.trait_value = '#{contractInfo.tag_element11}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element12.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 12 where trait_values.trait_value = '#{contractInfo.tag_element12}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element13.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 13 where trait_values.trait_value = '#{contractInfo.tag_element13}' and trait_values.address = '#{contractInfo.contract_address}'"
        end
        if contractInfo.tag_element14.present?
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 14 where trait_values.trait_value = '#{contractInfo.tag_element14}' and trait_values.address = '#{contractInfo.contract_address}'"
        end

        if contractInfo.contract_address == "0x517bce2ddbc21b9a8771dfd3db40404bdef1272d" ## moopunk
            sql = "select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 0 where trait_values.trait_value = '#{contractInfo.tag_element0}' and trait_values.address = '#{contractInfo.contract_address}'"
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 1 where trait_values.trait_value = '#{contractInfo.tag_element1}' and trait_values.address = '#{contractInfo.contract_address}'"
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 1 where trait_values.trait_value = '#{contractInfo.tag_element2}' and trait_values.address = '#{contractInfo.contract_address}'"
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 1 where trait_values.trait_value = '#{contractInfo.tag_element3}' and trait_values.address = '#{contractInfo.contract_address}'"
            sql = sql + " union select use_count from trait_values JOIN trait_types type on trait_values.trait_type = type .trait_type and "
            sql = sql + "type.trait_index = 1 where trait_values.trait_value = '#{contractInfo.tag_element4}' and trait_values.address = '#{contractInfo.contract_address}'"
        end


        total_sum = 0
        results = ActiveRecord::Base.connection.execute(sql)
        if results.present?
            results.each do |row|
                if row.first > 0
                    value = row.first.to_f
                    percent = (row.first * 100.to_f) / totalCount.to_f
                    if percent > 0
                        total_sum += 100.to_f / percent.to_f
                    end
                end
            end
        end

        return total_sum
    end

    def runningQuery(query)
        results = ActiveRecord::Base.connection.execute(query)
        if results.present?
            results.each do |row|
                puts row
            end
        end
    end

    def drawTextToNomImage(text, imageId)
        draw_text = text
        perline_charactor = 10
        if text.length > perline_charactor
            drawTextIndex = 0
            textArray = []
            while drawTextIndex <= text.length
                textArray.push(text.from(drawTextIndex).first(perline_charactor))
                drawTextIndex = drawTextIndex + perline_charactor
            end
            draw_text = textArray.map {|str| "#{str}"}.join("\n")
        end
        imagePath = "#{Rails.root}/public/nomspace.png"
        fontPath = "#{Rails.root}/public/Sen-Bold.ttf"
        outpath = "#{Rails.root}/public/nomdom/#{imageId}.png"

        img = Magick::ImageList.new(imagePath)
        txt = Magick::Draw.new
        img.annotate(txt, 0,0,0,0, draw_text) do
            txt.gravity = Magick::CenterGravity
            txt.pointsize = 60
            txt.fill = "#5452FC"
            txt.font = fontPath
        end
        img.write(outpath)
    end

end
