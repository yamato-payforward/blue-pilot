# Fear & Greed Index。市場全体のセンチメントを 0〜100 で表す日次指標。
#
# 銘柄ごとではなく市場全体の指標のため、instrument への参照を持たない。
# なお算出根拠にボラティリティ・モメンタムなど価格由来の要素が含まれるため、
# テクニカル指標と情報が一部重複する（Funding や OI ほど独立していない）。
class CreateFearGreedIndices < ActiveRecord::Migration[8.1]
  def change
    create_table :fear_greed_indices do |t|
      t.date :recorded_on, null: false
      t.integer :value, null: false          # 0〜100
      t.string :classification               # "Extreme Fear" など

      t.timestamps
    end

    add_index :fear_greed_indices, :recorded_on, unique: true
  end
end
