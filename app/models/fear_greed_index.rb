# 市場全体のセンチメント指標。銘柄に紐づかないため instrument への参照を持たない。
class FearGreedIndex < ApplicationRecord
  validates :recorded_on, :value, presence: true
  validates :recorded_on, uniqueness: true
  validates :value, inclusion: { in: 0..100 }

  scope :chronological, -> { order(:recorded_on) }
  scope :until_date, ->(date) { where(recorded_on: ..date) }
end
