require "test_helper"

class InstrumentTest < ActiveSupport::TestCase
  test "builds the symbol used by the exchange API" do
    instrument = Instrument.new(exchange: "binance", base: "BTC", quote: "USDT")

    assert_equal "BTCUSDT", instrument.api_symbol
  end

  test "defaults to the perpetual market" do
    instrument = Instrument.create!(exchange: "binance", base: "BTC", quote: "USDT")

    assert_equal "perpetual", instrument.market_type
  end

  test "rejects an unknown market type" do
    instrument = Instrument.new(exchange: "binance", base: "BTC", quote: "USDT", market_type: "futures")

    assert_not instrument.valid?
  end

  test "rejects a duplicate pair on the same exchange and market" do
    Instrument.create!(exchange: "binance", base: "BTC", quote: "USDT")
    duplicate = Instrument.new(exchange: "binance", base: "BTC", quote: "USDT")

    assert_not duplicate.valid?
  end

  test "allows the same pair on a different market type" do
    Instrument.create!(exchange: "binance", base: "BTC", quote: "USDT", market_type: "perpetual")
    spot = Instrument.new(exchange: "binance", base: "BTC", quote: "USDT", market_type: "spot")

    assert spot.valid?
  end

  test "active scope excludes instruments no longer collected" do
    live = Instrument.create!(exchange: "binance", base: "BTC", quote: "USDT")
    Instrument.create!(exchange: "binance", base: "ETH", quote: "USDT", active: false)

    assert_equal [ live ], Instrument.active.to_a
  end
end
