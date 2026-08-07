class Candle < ApplicationRecord
  belongs_to :instrument

  validates :timeframe, :open_time, presence: true
  validates :open, :high, :low, :close, :volume, presence: true
  validates :open_time, uniqueness: { scope: %i[instrument_id timeframe] }
  validate :high_is_highest
  validate :low_is_lowest

  scope :timeframe, ->(tf) { where(timeframe: tf) }
  scope :chronological, -> { order(:open_time) }
  scope :until_time, ->(time) { where(open_time: ..time) }

  # 成行買いが出来高に占める割合。0.5 より大きければ買い手が積極的に叩いている。
  # 通常の volume は売買の総量なので、これを見ないとどちら側が主導したか分からない。
  def taker_buy_ratio
    return nil if taker_buy_base_volume.nil? || volume.nil? || volume.zero?

    taker_buy_base_volume / volume
  end

  # 1約定あたりの平均サイズ。大口が動いているか小口の集積かの判別に使う。
  def average_trade_size
    return nil if trades_count.nil? || trades_count.zero? || volume.nil?

    volume / trades_count
  end

  private

  def high_is_highest
    return if [ high, open, low, close ].any?(&:nil?)

    errors.add(:high, "must be the highest price") if high < [ open, low, close ].max
  end

  def low_is_lowest
    return if [ low, open, high, close ].any?(&:nil?)

    errors.add(:low, "must be the lowest price") if low > [ open, high, close ].min
  end
end
