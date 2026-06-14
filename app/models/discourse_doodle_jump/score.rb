# frozen_string_literal: true

module DiscourseDoodleJump
  class Score < ActiveRecord::Base
    self.table_name = "doodle_jump_scores"

    belongs_to :user

    validates :user_id, presence: true, uniqueness: true
    validates :score,
              presence: true,
              numericality: {
                only_integer: true,
                greater_than: 0,
                less_than: 10_000_000,
              }
  end
end
