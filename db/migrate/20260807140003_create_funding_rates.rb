# 資金調達率。無期限先物で、買い方と売り方のどちらが相手に支払うかを表す。
#
# プラス = 買い方が売り方に支払う（買いに偏っている＝過熱）
# マイナス = 売り方が買い方に支払う
#
# 価格からは導出できない「市場の内部状態」であり、8時間ごとにしか発生しないため
# candles とは別テーブルにする。
class CreateFundingRates < ActiveRecord::Migration[8.1]
  def change
    create_table :funding_rates do |t|
      # 複合ユニークインデックスの先頭が instrument_id なので単体 index は作らない
      t.references :instrument, null: false, foreign_key: true, index: false
      t.datetime :funding_time, null: false
      t.decimal :funding_rate, precision: 20, scale: 10, null: false

      t.timestamps
    end

    add_index :funding_rates, %i[instrument_id funding_time], unique: true
  end
end
