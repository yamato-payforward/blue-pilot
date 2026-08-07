# ベーシス（先物価格と現物指数価格の乖離）。
#
#   basis_pct = (mark_price - index_price) / index_price
#   プラスが大きい … 先物が現物より高い（強気に傾いている＝過熱）
#   マイナス       … 先物が現物より安い（弱気）
#
# Funding Rate と近い情報を持つが、Funding が8時間ごとにしか発生しないのに対し
# ベーシスは連続的に観測できるため、より細かい変化を捉えられる。
# mark/index はローソク足形式のエンドポイントで遡れるため、収集を急ぐ必要はない。
class CreatePremiumIndices < ActiveRecord::Migration[8.1]
  def change
    create_table :premium_indices do |t|
      t.references :instrument, null: false, foreign_key: true
      t.datetime :recorded_at, null: false
      t.decimal :mark_price, precision: 20, scale: 8, null: false
      t.decimal :index_price, precision: 20, scale: 8, null: false
      t.decimal :basis_pct, precision: 20, scale: 10, null: false

      t.timestamps
    end

    add_index :premium_indices, %i[instrument_id recorded_at], unique: true
  end
end
