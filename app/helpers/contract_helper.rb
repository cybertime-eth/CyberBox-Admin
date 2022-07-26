module ContractHelper
    GRAPHQL_ENDPOINT = "https://api.thegraph.com/subgraphs/name/itdev-1210/cert-minter-v2"
    GRAPHQL_TOKEN = "3f88570f315c4e18886a286382acfa72"
    
    def fetchAllContractDetail
        logger.info("---------fetchAllContractDetail started -------")
        contracts_data = fetchTheGraphAllContracts()
        contracts_data.each do |contract_data|
            saveContractModel(contract_data)
        end

        #ContractInfo.where(contract_info_id:"1054_gang")

        logger.info("---------fetchAllContractDetail completed -------")
    end

    def fetchImageForContract(contractInfo)
        nftSybol = contractInfo.nft_symbol
        contract_id = contractInfo.contract_id

    end

    def fetchContractDetail(nftAddress)
        logger.info("---------fetchContractDetail #{nftAddress} -------")
        contract_data = fetchTheGraphContract(nftAddress)
        saveContractModel(contract_data)
        all_mint_count =  contract_data.mint_count
        nftSymbol = contract_data.nft_symbol
        start_index = 0
        per_page_count = 100
        if nftAddress == "0x046d19c5e5e8938d54fb02dcc396acf7f275490a"
            nftSymbol = "nomdom"
            start_index = 43469
        end
        
        while start_index < all_mint_count
            contractInfo_datas = fetchTheGraphContractDetail(start_index, start_index + per_page_count, nftSymbol)
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
            makeS3Images(contractInfo)
        end
    end

    def fetchAllErrorImages
        allErrors = ErrorImageItem.all
        allErrors.each do |error_item|
            # error_item.destroy()
            contract_name = error_item.contract_name
            fetchIPFSImage(contract_name)
        end
        logger.info("---------fetchAllErrorImages completed -------")
    end

    def fetchAllTraitValues(address)
        from = 0
        fetch_count = 100
        page_count = 100

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
        fetch_count = 100
        page_count = 100
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

    def saveContractInfoModel(contractInfosData, image_fetch = true)
        puts "# saveContractInfoModel #{contractInfosData.id}}"
        contract_info_id = contractInfosData.id
        @contractInfo = ContractInfo.where(contract_info_id: contract_info_id).first
        if @contractInfo.blank?
            @contractInfo = ContractInfo.new
        end
        nftSymbol = contractInfosData.contract
        if contractInfosData.contract_address == "0x046d19c5e5e8938d54fb02dcc396acf7f275490a"
            nftSymbol = "nomdom"
        end

        @contractInfo.contract_info_id = contractInfosData.id
        @contractInfo.contract =  nftSymbol
        @contractInfo.contract_id =  contractInfosData.contract_id
        @contractInfo.price =  contractInfosData.price
        @contractInfo.seller =  contractInfosData.seller
        @contractInfo.owner =  contractInfosData.owner
        @contractInfo.contract_address =  contractInfosData.contract_address
        @contractInfo.nftSymbol =  nftSymbol
        @contractInfo.market_status =  contractInfosData.market_status
        @contractInfo.dna =  contractInfosData.dna
        @contractInfo.name =  contractInfosData.name
        if contractInfosData.contract_address == "0xc017019e7b1566900553987ac1d9b25d126da16c"
        else
            @contractInfo.description =  contractInfosData.description
        end
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
        
        # if @contractInfo.nftSymbol != "christmaspunk"
            makeThumbnail(@contractInfo, image_fetch)
        # end
    end

    def drawTextToNomImage(text, imageId)
        imagePath = "#{Rails.root}/public/nomspace.png"
        fontPath = "#{Rails.root}/public/Arial-Unicode-Bold.ttf"
        outpath = "#{Rails.root}/public/temp/nom.png"
        
        font_size = 60
        if text.length > 0
            font_size = 60
        elsif text.length >12
            font_size = 55
        elsif text.length > 24
            font_size = 50
        elsif text.length > 30
            font_size = 40
        else
            font_size = 50
        end
        text_st_pos_x = 45
        text_st_pos_y = 251
        text_limit_width = 410
        text_limit_height = 200

        draw_text = getMultilineText(text, ".nom", fontPath, font_size, text_limit_width)

        if checkStringHaveEmoji(draw_text) == true
            text_st_pos_y = 220
            outpath_img = "#{Rails.root}/public/temp/nom_text.png"
            system("convert -pointsize #{font_size} -fill '#5452FC' -font '#{fontPath}' -background '#F2F3F5' pango:'#{draw_text}' #{outpath_img}")
            backImg = Magick::ImageList.new(imagePath)
            overlap_img = Magick::ImageList.new(outpath_img)
            combined_image = backImg.composite(overlap_img,text_st_pos_x, text_st_pos_y, Magick::OverCompositeOp)
            combined_image.format = "png"
            combined_image.write(outpath)

        else
            img = Magick::ImageList.new(imagePath)
            txt = Magick::Draw.new
            img.annotate(txt, text_limit_width, text_limit_height , text_st_pos_x, text_st_pos_y,  draw_text) do 
                txt.pointsize = font_size
                txt.fill = "#5452FC"
                txt.font = fontPath
                txt.align = Magick::LeftAlign
            end
            img.write(outpath)
        end
    end

    def makeS3Images(contract_info_obj)
        Aws.config.update({
        region: 'us-east-2',
        credentials: Aws::Credentials.new("AKIAZPV4RETFNFILD6PX", "QHv6fqElWhYgn63gWrZWGNlb0wFFUfpR/meu4ykQ"),
        })
        s3 = Aws::S3::Resource.new(region: 'us-east-2')
        bucket = 'cdn-cyberbox'

        nftSymbol = contract_info_obj.nftSymbol
        contract_id = contract_info_obj.contract_id
        imageUrl = contract_info_obj.image

        puts "# makeThumbnail Start #{nftSymbol} #{contract_id}"

        if contract_info_obj.nftSymbol == "nomdom"

            imageName = contract_info_obj.image
            imagePath = "#{Rails.root}/public/temp/nom.png"

            check_obj = s3.bucket(bucket).object("280/#{nftSymbol}/#{imageName}.cwebp")
            if check_obj.exists? == true
                return
            end

            if File.exist?(imagePath) == true
                File.delete(imagePath)
            end
            if File.exist?(imagePath) == false
                # File.delete(imagePath)
                drawTextToNomImage(contract_info_obj.name, imageName)
                outpath = "#{Rails.root}/public/temp/nom.png"

                obj = s3.bucket(bucket).object("500/#{nftSymbol}/#{imageName}.cwebp")
                obj.upload_file(outpath, {acl: 'public-read'})

                outpath_280 = "#{Rails.root}/public/temp/nom_280.png"
                MiniMagick.configure do |config|
                    config.timeout = 2
                end
                image = MiniMagick::Image.open(outpath)
                image.resize "280x280"
                image.format "cwebp"
                image.write(outpath_280)
                File.chmod(0777, outpath_280)

                obj = s3.bucket(bucket).object("280/#{nftSymbol}/#{imageName}.cwebp")
                obj.upload_file(outpath_280, {acl: 'public-read'})
            end
        else
            check_obj = s3.bucket(bucket).object("280/#{nftSymbol}/#{contract_id}.cwebp")
            if nftSymbol == "christmaspunk"
                check_obj = s3.bucket(bucket).object("280/#{nftSymbol}/#{contract_id}.gif")
            end
            if check_obj.exists? == false
                begin
                    if imageUrl.include? "ipfs://"
                        imageUrl["ipfs://"]= "https://ipfs.io/ipfs/"
                    end
                    imageFormat = File.extname(URI.parse(imageUrl).path)
                    if imageFormat.include? "."
                        imageFormat["."] = ""
                    end
            
                    FileUtils.mkdir_p "#{Rails.root}/public/temp/500#{nftSymbol}"
                    FileUtils.mkdir_p "#{Rails.root}/public/temp/250#{nftSymbol}"
            
                    targetFileName_500 = "#{Rails.root}/public/temp/500#{nftSymbol}/#{contract_id}.cwebp"
                    targetFileName_280 = "#{Rails.root}/public/temp/250#{nftSymbol}/#{contract_id}.cwebp"
                    if imageFormat == "gif"
                        targetFileName_500 = "#{Rails.root}/public/temp/500#{nftSymbol}/#{contract_id}.gif"
                        targetFileName_280 = "#{Rails.root}/public/temp/250#{nftSymbol}/#{contract_id}.gif"
                    end
            
                    if File.exist?(targetFileName_500) == true
                        File.delete(targetFileName_500)
                    end
            
                    MiniMagick.configure do |config|
                        config.timeout = 2
                    end
                    image = MiniMagick::Image.open(imageUrl)
                    image.resize "500x500"
                    image.format "cwebp"
                    image.write(targetFileName_500)
                    File.chmod(0777, targetFileName_500)
                    name = File.basename(targetFileName_500)
                    obj = s3.bucket(bucket).object("500/" + nftSymbol + "/" + name)
                    obj.upload_file(targetFileName_500, {acl: 'public-read'})
                    
                    if File.exist?(targetFileName_280) == true
                        File.delete(targetFileName_280)
                    end
                    
                    image.resize "280x280"
                    image.write(targetFileName_280)
                    File.chmod(0777, targetFileName_280)
            
                    name = File.basename(targetFileName_280)
                    obj = s3.bucket(bucket).object("280/" + nftSymbol + "/" + name)
                    obj.upload_file(targetFileName_280, {acl: 'public-read'})
                rescue => e
                    puts "# makeThumbnail error"
                    @errorItem = ErrorImageItem.create(contract_info_id: contract_info_obj.id, contract_name: contract_info_obj.contract_info_id)
                    # sleep(30)
                end
            end
        end
        
    end

    # https://cybertime.mypinata.cloud/ipfs/QmZf4KzmjUku952irRoXUpPGJ5qp1NBvdEEQCFcy2rm3VS/5.jpg
    def makeCBCNThumbImage
        FileUtils.mkdir_p "#{Rails.root}/public/CBCN/"
        FileUtils.mkdir_p "#{Rails.root}/public/CBCN/thumb"
        FileUtils.mkdir_p "#{Rails.root}/public/CBCN/detail"

        for index in [1,2,3,4,5,6,7,8,9,10,11,12,13] do
            imageUrl = "https://cybertime.mypinata.cloud/ipfs/QmZf4KzmjUku952irRoXUpPGJ5qp1NBvdEEQCFcy2rm3VS/#{index}.jpg" 
            imagePath_thumb = "#{Rails.root}/public/CBCN/thumb/#{index}.png"
            if File.exist?(imagePath_thumb) == false
                MiniMagick.configure do |config|
                    config.timeout = 2
                end
                image = MiniMagick::Image.open(imageUrl)
                image.resize "280x280"
                image.format "png"
                image.write(imagePath_thumb)
                File.chmod(0777, imagePath_thumb)
            end
            imagePath_detail = "#{Rails.root}/public/CBCN/detail/#{index}.png"
            if File.exist?(imagePath_detail) == false
                MiniMagick.configure do |config|
                    config.timeout = 2
                end
                image = MiniMagick::Image.open(imageUrl)
                image.resize "500x500"
                image.format "png"
                image.write(imagePath_detail)
                File.chmod(0777, imagePath_detail)
            end
        end
    end

    # //"ipfs://QmNcjPTYFFsDosWAXFzefUX9y7hsVjXDPRr2hw5MhPdGoo/245.png"
    # https://ipfs.io/ipfs/QmNcjPTYFFsDosWAXFzefUX9y7hsVjXDPRr2hw5MhPdGoo/123.png
    def makeThumbnail(contract_info_obj, image_fetch = true)
        # if contract_info_obj.nftSymbol == "nomdom"
        #     puts "#{contract_info_obj.contract_id}"
        #     imageName = contract_info_obj.image
        #     imagePath = "#{Rails.root}/public/#{contract_info_obj.nftSymbol}/#{imageName}.png"
        #     if File.exist?(imagePath) == false
        #         FileUtils.mkdir_p "#{Rails.root}/public/#{contract_info_obj.nftSymbol}/"
        #         drawTextToNomImage(contract_info_obj.name, imageName)
        #     end
        #     return
        # end
        makeS3Images(contract_info_obj)
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
                contractInfos(where:{nftSymbol:"#{nftSymbol}", contract_id_lt:count + 1, contract_id_gt:from - 1}) do
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


    def checkStringHaveEmoji(str)
        str.scan(/[\u{00A9}\u{00AE}\u{203C}\u{2049}\u{2122}\u{2139}\u{2194}-\u{2199}\u{21A9}-\u{21AA}\u{231A}-\u{231B}\u{23E9}-\u{23EC}\u{23F0}\u{23F3}\u{24C2}\u{25AA}-\u{25AB}\u{25B6}\u{25C0}\u{25FB}-\u{25FE}\u{2600}-\u{2601}\u{260E}\u{2611}\u{2614}-\u{2615}\u{261D}\u{263A}\u{2648}-\u{2653}\u{2660}\u{2663}\u{2665}-\u{2666}\u{2668}\u{267B}\u{267F}\u{2693}\u{26A0}-\u{26A1}\u{26AA}-\u{26AB}\u{26BD}-\u{26BE}\u{26C4}-\u{26C5}\u{26CE}\u{26D4}\u{26EA}\u{26F2}-\u{26F3}\u{26F5}\u{26FA}\u{26FD}\u{2702}\u{2705}\u{2708}-\u{270C}\u{270F}\u{2712}\u{2714}\u{2716}\u{2728}\u{2733}-\u{2734}\u{2744}\u{2747}\u{274C}\u{274E}\u{2753}-\u{2755}\u{2757}\u{2764}\u{2795}-\u{2797}\u{27A1}\u{27B0}\u{27BF}\u{2934}-\u{2935}\u{2B05}-\u{2B07}\u{2B1B}-\u{2B1C}\u{2B50}\u{2B55}\u{3030}\u{303D}\u{3297}\u{3299}\u{1F004}\u{1F0CF}\u{1F170}-\u{1F171}\u{1F17E}-\u{1F17F}\u{1F18E}\u{1F191}-\u{1F19A}\u{1F201}-\u{1F202}\u{1F21A}\u{1F22F}\u{1F232}-\u{1F23A}\u{1F250}-\u{1F251}\u{1F300}-\u{1F31F}\u{1F330}-\u{1F335}\u{1F337}-\u{1F37C}\u{1F380}-\u{1F393}\u{1F3A0}-\u{1F3C4}\u{1F3C6}-\u{1F3CA}\u{1F3E0}-\u{1F3F0}\u{1F400}-\u{1F43E}\u{1F440}\u{1F442}-\u{1F4F7}\u{1F4F9}-\u{1F4FC}\u{1F500}-\u{1F507}\u{1F509}-\u{1F53D}\u{1F550}-\u{1F567}\u{1F5FB}-\u{1F640}\u{1F645}-\u{1F64F}\u{1F680}-\u{1F68A}\u{1F68C}-\u{1F6C5}]/).present?
    end

    def getMultilineText(text, extension, fontUrl, fontSize, limitLength)
        multilineText = ""
        if text.length < 5
            multilineText = text + extension
        else
            label = Magick::Draw.new
            label.font = fontUrl
            label.pointsize = fontSize
            label.text(0,0,text)

            calcPosition = 1
            chipPoint = 0
            last_width = 0
            while calcPosition <= text.length
                subString = text[chipPoint...calcPosition]
                metrics = label.get_type_metrics(subString)
                width = metrics.width
                last_width = width
                if width < limitLength
                    multilineText = multilineText + text[calcPosition-1...calcPosition]
                    calcPosition = calcPosition + 1
                else
                    multilineText = multilineText + '\n'
                    chipPoint = calcPosition - 1
                end
            end

            label = Magick::Draw.new
            label.font = fontUrl
            label.pointsize = fontSize
            label.text(0,0,extension)
            metrics = label.get_type_metrics(extension)
            width = metrics.width

            if last_width + width < limitLength
                multilineText = multilineText + extension
            else
                multilineText = multilineText + '\n' + extension
            end
        end
        multilineText
    end

    def cronJobRefreshing
        logger.info("---------fetch All Contracts -------")
        contracts_data = fetchTheGraphAllContracts()
        contracts_data.each do |contract_data|
            nft_symbol = contract_data.nft_symbol
            logger.info("---------fetch All NFTs on #{nft_symbol} -------")
            @contract = Contract.where(nftSymbol: nft_symbol).first
            if @contract.present?
                db_mint_count = @contract.mint_count
                gf_mint_count = contract_data.mint_count
                logger.info("---------fetch All NFTs on #{gf_mint_count} / #{db_mint_count} -------")
                if db_mint_count < gf_mint_count
                    saveContractModel(contract_data)
                    start_index = db_mint_count
                    per_page_count = 100
                    while start_index < gf_mint_count
                        contractInfo_datas = fetchTheGraphContractDetail(start_index, start_index + per_page_count, nft_symbol)
                        contractInfo_datas.each do |contractInfo_data|
                            saveContractInfoModel(contractInfo_data, false)
                        end
                        start_index = start_index + per_page_count
                    end
                    logger.info("---------start new-ranking -------")
                    contract_address = @contract.nftAddress
                    if contract_address != "0x046d19c5e5e8938d54fb02dcc396acf7f275490a" # nomdom
                    elsif contract_address != "0x1f25f8df9e33033668d6f04dae0bde4854e9f1a5" # knoxnft
                    elsif contract_address != "5167545246389352752" # CyberBoxCertNFT
                    else
                        logger.info("---------fetchAllTraitValues -------")
                        fetchAllTraitValues(contract_address)
                        logger.info("---------makeRating -------")
                        makeRating(contract_address)
                    end
                end

            end

        end
    end

end
