require "test_helper"

class CandleTest < ActiveSupport::TestCase
  setup do
    @instrument = Instrument.create!(exchange: "binance", base: "BTC", quote: "USDT")
    @attrs = {
      timeframe: "1h",
      open_time: Time.utc(2026, 8, 7, 12),
      open: 100_000, high: 101_000, low: 99_000, close: 100_500,
      volume: 12.5, quote_volume: 1_250_000, trades_count: 500,
      taker_buy_base_volume: 7.5, taker_buy_quote_volume: 750_000
    }
  end

  test "stores a candle with the extended kline fields" do
    candle = @instrument.candles.create!(@attrs)

    assert_equal 500, candle.trades_count
    assert_equal 7.5, candle.taker_buy_base_volume
  end

  # 同じ足を再取得しても壊れないこと（ジョブのリトライで重複させない）
  test "rejects a duplicate of the same instrument, timeframe and open_time" do
    @instrument.candles.create!(@attrs)
    duplicate = @instrument.candles.new(@attrs)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:open_time], "has already been taken"
  end

  test "allows the same open_time on a different timeframe" do
    @instrument.candles.create!(@attrs)
    other = @instrument.candles.new(@attrs.merge(timeframe: "4h"))

    assert other.valid?
  end

  test "rejects a high below the other prices" do
    candle = @instrument.candles.new(@attrs.merge(high: 99_500))

    assert_not candle.valid?
    assert_includes candle.errors[:high], "must be the highest price"
  end

  test "rejects a low above the other prices" do
    candle = @instrument.candles.new(@attrs.merge(low: 100_800))

    assert_not candle.valid?
    assert_includes candle.errors[:low], "must be the lowest price"
  end

  test "taker_buy_ratio reports which side was aggressive" do
    candle = @instrument.candles.create!(@attrs)

    assert_equal 0.6, candle.taker_buy_ratio.to_f
  end

  test "taker_buy_ratio is nil when the field was not collected" do
    candle = @instrument.candles.create!(@attrs.merge(taker_buy_base_volume: nil))

    assert_nil candle.taker_buy_ratio
  end

  test "average_trade_size divides volume by the number of trades" do
    candle = @instrument.candles.create!(@attrs.merge(volume: 100, trades_count: 40))

    assert_equal 2.5, candle.average_trade_size.to_f
  end

  test "average_trade_size is nil when there were no trades" do
    candle = @instrument.candles.create!(@attrs.merge(trades_count: 0))

    assert_nil candle.average_trade_size
  end

  test "prices keep full decimal precision" do
    candle = @instrument.candles.create!(@attrs.merge(close: "100500.12345678"))

    assert_equal BigDecimal("100500.12345678"), candle.reload.close
  end
end
