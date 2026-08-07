# 建玉残高。決済されずに残っているポジションの総量。
#
# 価格と組み合わせて初めて意味が出るデータで、OHLCV からは導出できない。
#   価格↑ + OI↑ … 新規の買いが入っている（トレンドが強い）
#   価格↑ + OI↓ … 売り方の買い戻し（上昇が終わりかけ）
# この2つは OHLCV 上ではどちらも同じ陽線であり区別できない。
#
# Binance の該当エンドポイントは直近30日程度しか返さないため、過ぎた分は取得できない。
# 使う予定がなくても収集だけ先に始める必要がある。
class CreateOpenInterests < ActiveRecord::Migration[8.1]
  def change
    create_table :open_interests do |t|
      t.references :instrument, null: false, foreign_key: true
      t.datetime :recorded_at, null: false
      t.decimal :open_interest, precision: 30, scale: 8, null: false       # 契約数
      t.decimal :open_interest_value, precision: 30, scale: 8              # 金額換算

      t.timestamps
    end

    add_index :open_interests, %i[instrument_id recorded_at], unique: true
  end
end
