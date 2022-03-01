# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_02_28_091203) do
  create_table "active_admin_comments", charset: "utf8mb4", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "contract_infos", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "contract_info_id"
    t.string "contract"
    t.integer "contract_id"
    t.integer "price"
    t.string "seller"
    t.string "owner"
    t.string "contract_address"
    t.string "nftSymbol"
    t.string "market_status"
    t.string "dna"
    t.string "name"
    t.string "description"
    t.string "attributeString"
    t.string "image"
    t.integer "tag_attribute_count"
    t.string "tag_element0"
    t.string "tag_element1"
    t.string "tag_element2"
    t.string "tag_element3"
    t.string "tag_element4"
    t.string "tag_element5"
    t.string "tag_element6"
    t.string "tag_element7"
    t.string "tag_element8"
    t.string "tag_element9"
    t.string "tag_element10"
    t.string "tag_element11"
    t.string "tag_element12"
    t.string "tag_element13"
    t.string "tag_element14"
    t.string "tag_element15"
  end

  create_table "contracts", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "contract_id"
    t.string "title"
    t.string "nftName"
    t.string "nftSymbol"
    t.string "nftAddress"
    t.string "erc20Name"
    t.string "erc20Symbol"
    t.string "erc20Address"
    t.string "marketPlaceAddress"
    t.integer "marketFee"
    t.string "marketPlaceFeeAddress"
    t.integer "createrFee"
    t.string "tokenCreaterAddress"
    t.integer "producerFee"
    t.string "tokenProducerAddress"
    t.integer "ownerCount"
    t.integer "mint_count"
    t.integer "bid_count"
    t.integer "list_count"
    t.integer "sell_count"
    t.integer "sell_max_price"
    t.integer "sell_min_price"
    t.integer "sell_total_price"
    t.integer "dna_count"
    t.integer "traitTypesCount"
  end

  create_table "error_image_items", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "contract_info_id"
    t.string "contract_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_info_id"], name: "index_error_image_items_on_contract_info_id"
  end

  create_table "trait_values", charset: "utf8mb4", force: :cascade do |t|
    t.string "trait_id"
    t.string "address"
    t.string "nft_symbol"
    t.string "trait_type"
    t.string "trait_value"
    t.integer "use_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
