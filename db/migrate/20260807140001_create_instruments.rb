# 取引対象の銘柄マスタ。
#
# テーブル名を symbols にしないのは、モデル名が Ruby 組み込みの Symbol と
# 衝突するため。instrument は金融分野で「取引される商品」を指す一般的な語。
class CreateInstruments < ActiveRecord::Migration[8.1]
  def change
    create_table :instruments do |t|
      t.string :exchange, null: false                          # binance
      t.string :base, null: false                              # BTC
      t.string :quote, null: false                             # USDT
      t.string :market_type, null: false, default: "perpetual" # perpetual / spot
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :instruments,
              %i[exchange base quote market_type],
              unique: true,
              name: "index_instruments_on_exchange_and_pair"

    # 収集ジョブは insert_all / upsert_all を使うためモデルのバリデーションを
    # 経由しない。想定外の値が入らないよう DB 側でも制約する。
    add_check_constraint :instruments,
                         "market_type IN ('perpetual', 'spot')",
                         name: "instruments_market_type_check"
  end
end
