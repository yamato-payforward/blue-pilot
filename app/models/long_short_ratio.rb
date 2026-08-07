class LongShortRatio < ApplicationRecord
  # Binance の4エンドポイントに対応する。形が同じなので1テーブルで扱う。
  RATIO_TYPES = %w[global_account top_account top_position taker].freeze

  belongs_to :instrument

  validates :recorded_at, :long_value, :short_value, :ratio, presence: true
  validates :ratio_type, inclusion: { in: RATIO_TYPES }
  validates :recorded_at, uniqueness: { scope: %i[instrument_id ratio_type] }

  scope :of_type, ->(type) { where(ratio_type: type) }
  scope :chronological, -> { order(:recorded_at) }
  scope :until_time, ->(time) { where(recorded_at: ..time) }
end
