class PremiumIndex < ApplicationRecord
  belongs_to :instrument

  validates :recorded_at, :mark_price, :index_price, :basis_pct, presence: true
  validates :recorded_at, uniqueness: { scope: :instrument_id }

  scope :chronological, -> { order(:recorded_at) }
  scope :until_time, ->(time) { where(recorded_at: ..time) }

  # mark と index から basis_pct を求める。保存前に呼ぶ想定。
  # 外部 API のレスポンスが欠損していても例外にせず nil を返す。
  def self.basis_pct_for(mark_price:, index_price:)
    return nil if mark_price.nil? || index_price.nil? || index_price.zero?

    (mark_price - index_price) / index_price
  end
end
