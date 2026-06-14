# frozen_string_literal: true

module DiscourseDoodleJump
  class PlayController < ::ApplicationController
    requires_plugin DiscourseDoodleJump::PLUGIN_NAME

    skip_before_action :check_xhr,
                       :verify_authenticity_token,
                       :redirect_to_login_if_required,
                       :redirect_to_profile_if_required
    skip_before_action :preload_json

    before_action :ensure_enabled

    MIME_TYPES = {
      "html" => "text/html",
      "css" => "text/css",
      "js" => "application/javascript",
      "png" => "image/png",
      "jpg" => "image/jpeg",
      "jpeg" => "image/jpeg",
      "gif" => "image/gif",
      "svg" => "image/svg+xml",
      "mp3" => "audio/mpeg",
      "wav" => "audio/wav",
      "json" => "application/json",
    }.freeze

    def index
      serve_relative_path("index.html")
    end

    def show
      relative_path = params[:path].to_s
      raise Discourse::NotFound if relative_path.blank?

      serve_relative_path(relative_path)
    end

    private

    def ensure_enabled
      raise Discourse::NotFound unless SiteSetting.doodle_jump_enabled
    end

    def serve_relative_path(relative_path)
      normalized = Pathname.new(relative_path).cleanpath.to_s
      raise Discourse::NotFound if normalized.start_with?("..") || normalized.include?("../")

      full_path = File.join(DiscourseDoodleJump.game_root, normalized)
      raise Discourse::NotFound unless full_path.start_with?(DiscourseDoodleJump.game_root + File::SEPARATOR)
      raise Discourse::NotFound unless File.file?(full_path)

      extension = File.extname(full_path).delete_prefix(".")
      content_type = MIME_TYPES[extension] || "application/octet-stream"

      send_file(full_path, type: content_type, disposition: "inline")
    end
  end
end
