require "test_helper"

# Funding / OI / L-S Ratio / ベーシス / Fear & Greed の共通の性質を確認する。
# いずれも収集ジョブが再実行されても重複しないこと（冪等）が要。
class MarketDataTest < ActiveSupport::TestCase
  setup do
    @instrument = Instrument.create!(exchange: "binance", base: "BTC", quote: "USDT")
    @time = Time.utc(2026, 8, 7, 12)
  end

  test "funding rate rejects a duplicate at the same funding time" do
    @instrument.funding_rates.create!(funding_time: @time, funding_rate: "0.0001")
    duplicate = @instrument.funding_rates.new(funding_time: @time, funding_rate: "0.0001")

    assert_not duplicate.valid?
  end

  test "funding rate reports which side pays" do
    paying = @instrument.funding_rates.create!(funding_time: @time, funding_rate: "0.0001")
    receiving = @instrument.funding_rates.create!(funding_time: @time + 8.hours, funding_rate: "-0.0001")

    assert paying.longs_paying?
    assert_not receiving.longs_paying?
  end

  test "funding rate keeps precision for very small values" do
    rate = @instrument.funding_rates.create!(funding_time: @time, funding_rate: "0.0000012345")

    assert_equal BigDecimal("0.0000012345"), rate.reload.funding_rate
  end

  test "open interest rejects a duplicate at the same time" do
    @instrument.open_interests.create!(recorded_at: @time, open_interest: 85_000)
    duplicate = @instrument.open_interests.new(recorded_at: @time, open_interest: 85_000)

    assert_not duplicate.valid?
  end

  test "long short ratio allows each type at the same time" do
    LongShortRatio::RATIO_TYPES.each do |type|
      record = @instrument.long_short_ratios.new(
        ratio_type: type, recorded_at: @time,
        long_value: 0.65, short_value: 0.35, ratio: 1.857
      )

      assert record.valid?, "#{type} should be storable alongside the others"
      record.save!
    end

    assert_equal LongShortRatio::RATIO_TYPES.size, @instrument.long_short_ratios.count
  end

  test "long short ratio rejects a duplicate of the same type and time" do
    attrs = { ratio_type: "global_account", recorded_at: @time,
              long_value: 0.65, short_value: 0.35, ratio: 1.857 }
    @instrument.long_short_ratios.create!(attrs)

    assert_not @instrument.long_short_ratios.new(attrs).valid?
  end

  test "long short ratio rejects an unknown type" do
    record = @instrument.long_short_ratios.new(
      ratio_type: "whales", recorded_at: @time,
      long_value: 0.65, short_value: 0.35, ratio: 1.857
    )

    assert_not record.valid?
  end

  test "premium index computes basis from mark and index price" do
    basis = PremiumIndex.basis_pct_for(mark_price: BigDecimal("101000"), index_price: BigDecimal("100000"))

    assert_equal BigDecimal("0.01"), basis
  end

  test "premium index basis is nil without an index price" do
    assert_nil PremiumIndex.basis_pct_for(mark_price: BigDecimal("101000"), index_price: BigDecimal("0"))
  end

  test "premium index rejects a duplicate at the same time" do
    attrs = { recorded_at: @time, mark_price: 101_000, index_price: 100_000, basis_pct: "0.01" }
    @instrument.premium_indices.create!(attrs)

    assert_not @instrument.premium_indices.new(attrs).valid?
  end

  test "fear greed index is market wide and unique per day" do
    FearGreedIndex.create!(recorded_on: Date.new(2026, 8, 7), value: 72, classification: "Greed")
    duplicate = FearGreedIndex.new(recorded_on: Date.new(2026, 8, 7), value: 50)

    assert_not duplicate.valid?
  end

  test "fear greed index rejects a value outside the scale" do
    assert_not FearGreedIndex.new(recorded_on: Date.new(2026, 8, 7), value: 101).valid?
  end
end
