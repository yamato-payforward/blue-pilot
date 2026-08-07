class OpenInterest < ApplicationRecord
  belongs_to :instrument

  validates :recorded_at, :open_interest, presence: true
  validates :recorded_at, uniqueness: { scope: :instrument_id }

  scope :chronological, -> { order(:recorded_at) }
  scope :until_time, ->(time) { where(recorded_at: ..time) }
end
