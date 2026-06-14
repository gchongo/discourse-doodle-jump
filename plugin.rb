# frozen_string_literal: true

# name: discourse-doodle-jump
# about: Doodle Jump mini-game with standalone leaderboard for Discourse.
# version: 0.1.0
# authors: howhy.day
# url: https://www.howhy.day/

enabled_site_setting :doodle_jump_enabled

register_asset "stylesheets/common/doodle-jump.scss"

register_svg_icon "gamepad"

module ::DiscourseDoodleJump
  PLUGIN_NAME = "discourse-doodle-jump"

  def self.game_root
    File.expand_path("public/game", __dir__)
  end
end

require_relative "lib/discourse_doodle_jump/engine"
require_relative "lib/discourse_doodle_jump/leaderboard_service"
