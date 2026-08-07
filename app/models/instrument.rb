class Instrument < ApplicationRecord
  MARKET_TYPES = %w[perpetual spot].freeze

  has_many :candles, dependent: :destroy
  has_many :funding_rates, dependent: :destroy
  has_many :open_interests, dependent: :destroy
  has_many :long_short_ratios, dependent: :destroy
  has_many :premium_indices, dependent: :destroy

  validates :exchange, :base, :quote, presence: true
  validates :market_type, inclusion: { in: MARKET_TYPES }
  validates :base, uniqueness: { scope: %i[exchange quote market_type] }

  scope :active, -> { where(active: true) }

  # binance の API が使うシンボル表記（例: BTCUSDT）
  def api_symbol
    "#{base}#{quote}"
  end

  def to_s
    "#{exchange}:#{base}/#{quote}(#{market_type})"
  end
end
