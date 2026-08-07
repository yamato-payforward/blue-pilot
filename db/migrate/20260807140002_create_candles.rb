# ローソク足（OHLCV）。このアプリにおける唯一の真実で、指標は全てここから計算する。
#
# 後半4カラムは Binance の kline レスポンスに元から含まれており、追加の API コールは不要。
# 保存しなければ受信済みのデータを捨てることになる。
#   - volume / trades_count = 平均取引サイズ（大口か小口か）
#   - taker_buy_base_volume と volume の比 = 買い圧力か売り圧力か
class CreateCandles < ActiveRecord::Migration[8.1]
  def change
    create_table :candles do |t|
      # 複合ユニークインデックスの先頭が instrument_id なので単体 index は作らない
      t.references :instrument, null: false, foreign_key: true, index: false
      t.string :timeframe, null: false   # "1h"
      t.datetime :open_time, null: false # 足の開始時刻（UTC）

      # 価格は decimal。float は誤差が出るため金額に使わない
      t.decimal :open, precision: 20, scale: 8, null: false
      t.decimal :high, precision: 20, scale: 8, null: false
      t.decimal :low, precision: 20, scale: 8, null: false
      t.decimal :close, precision: 20, scale: 8, null: false

      t.decimal :volume, precision: 30, scale: 8, null: false
      t.decimal :quote_volume, precision: 30, scale: 8
      t.integer :trades_count
      t.decimal :taker_buy_base_volume, precision: 30, scale: 8
      t.decimal :taker_buy_quote_volume, precision: 30, scale: 8

      t.timestamps
    end

    # 同じ足を何度取得しても壊れないようにする（冪等）
    add_index :candles, %i[instrument_id timeframe open_time], unique: true
  end
end
