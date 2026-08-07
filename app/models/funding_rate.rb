class FundingRate < ApplicationRecord
  belongs_to :instrument

  validates :funding_time, :funding_rate, presence: true
  validates :funding_time, uniqueness: { scope: :instrument_id }

  scope :chronological, -> { order(:funding_time) }
  scope :until_time, ->(time) { where(funding_time: ..time) }

  # プラスなら買い方が支払う側（買いに偏っている）
  def longs_paying?
    funding_rate.positive?
  end
end
