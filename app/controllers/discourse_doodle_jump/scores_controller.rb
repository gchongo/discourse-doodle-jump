# frozen_string_literal: true

module DiscourseDoodleJump
  class ScoresController < ::ApplicationController
    requires_plugin DiscourseDoodleJump::PLUGIN_NAME

    before_action :ensure_enabled
    before_action :ensure_logged_in, only: [:create]

    def index
      discourse_expires_in 1.minute

      render_json_dump(LeaderboardService.payload(for_user: current_user))
    end

    def create
      ensure_not_rate_limited!

      score_value = params[:score].to_i
      if score_value <= 0 || score_value >= 10_000_000
        raise Discourse::InvalidParameters.new(:score)
      end

      result = LeaderboardService.submit_score!(current_user, score_value)
      render_json_dump(result)
    end

    private

    def ensure_enabled
      raise Discourse::NotFound unless SiteSetting.doodle_jump_enabled
    end

    def ensure_not_rate_limited!
      RateLimiter.new(current_user, "doodle-jump-score", 3, 60).performed!
    rescue RateLimiter::LimitExceeded => e
      render_json_error e.description, status: 429
    end
  end
end
