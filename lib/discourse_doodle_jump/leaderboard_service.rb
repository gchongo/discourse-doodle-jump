# frozen_string_literal: true

module DiscourseDoodleJump
  class LeaderboardService
    MIN_LIMIT = 5
    MAX_LIMIT = 50

    def self.limit
      SiteSetting.doodle_jump_leaderboard_size.to_i.clamp(MIN_LIMIT, MAX_LIMIT)
    end

    def self.payload(for_user: nil)
      limit = self.limit
      scores = Score.includes(:user).order(score: :desc, updated_at: :asc).limit(limit)

      leaderboard =
        scores.each_with_index.map do |score, index|
          DoodleJumpScoreSerializer.new(score, root: false, scope: Guardian.new(nil)).as_json.merge(
            rank: index + 1,
          )
        end

      personal = for_user ? personal_stats(for_user) : nil

      { leaderboard: leaderboard, personal: personal }
    end

    def self.personal_stats(user)
      score = Score.find_by(user_id: user.id)
      return nil unless score

      rank = rank_for(score)
      { rank: rank, score: score.score }
    end

    def self.rank_for(score)
      Score
        .where("score > :score OR (score = :score AND updated_at < :updated_at)", score: score.score, updated_at: score.updated_at)
        .count + 1
    end

    def self.submit_score!(user, score_value)
      record = Score.find_or_initialize_by(user_id: user.id)
      previous_score = record.score

      if record.new_record? || score_value > record.score
        record.score = score_value
        record.save!
        {
          updated: true,
          personal: {
            rank: rank_for(record),
            score: record.score,
            previous_score: previous_score,
          },
        }
      else
        {
          updated: false,
          personal: {
            rank: rank_for(record),
            score: record.score,
          },
        }
      end
    end
  end
end
