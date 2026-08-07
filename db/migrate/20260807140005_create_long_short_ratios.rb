# ロング／ショートの偏り。Binance には形の同じエンドポイントが4種類あるため、
# ratio_type で区別して1テーブルにまとめる。
#
#   global_account … 全体の口座ベース
#   top_account    … 大口トレーダーの口座ベース
#   top_position   … 大口トレーダーの建玉ベース
#   taker          … 成行の買い／売り比率（long_value=買い, short_value=売り）
#
# Open Interest と同様、直近30日程度しか遡れない。
class CreateLongShortRatios < ActiveRecord::Migration[8.1]
  def change
    create_table :long_short_ratios do |t|
      t.references :instrument, null: false, foreign_key: true
      t.string :ratio_type, null: false
      t.datetime :recorded_at, null: false
      t.decimal :long_value, precision: 20, scale: 8, null: false
      t.decimal :short_value, precision: 20, scale: 8, null: false
      t.decimal :ratio, precision: 20, scale: 8, null: false

      t.timestamps
    end

    add_index :long_short_ratios,
              %i[instrument_id ratio_type recorded_at],
              unique: true,
              name: "index_long_short_ratios_on_instrument_type_and_time"
  end
end
