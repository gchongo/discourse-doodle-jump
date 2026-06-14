# frozen_string_literal: true

module DiscourseDoodleJump
  class PlayController < ::ApplicationController
    requires_plugin DiscourseDoodleJump::PLUGIN_NAME

    skip_before_action :check_xhr,
                       :verify_authenticity_token,
                       :redirect_to_login_if_required,
                       :redirect_to_profile_if_required
    skip_before_action :preload_json
    skip_after_action :set_cross_origin_opener_policy_header

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
      serve_relative_path(resolved_asset_path)
    end

    private

    def ensure_enabled
      raise Discourse::NotFound unless SiteSetting.doodle_jump_enabled
    end

    def resolved_asset_path
      path = params[:path].to_s
      raise Discourse::NotFound if path.blank?

      path = "#{path}.#{params[:format]}" if params[:format].present?

      path
    end

    def serve_relative_path(relative_path)
      normalized = Pathname.new(relative_path).cleanpath.to_s
      raise Discourse::NotFound if normalized.start_with?("..") || normalized.include?("../")

      full_path = File.join(DiscourseDoodleJump.game_root, normalized)
      raise Discourse::NotFound unless full_path.start_with?(DiscourseDoodleJump.game_root + File::SEPARATOR)
      raise Discourse::NotFound unless File.file?(full_path)

      extension = File.extname(full_path).delete_prefix(".")
      content_type = MIME_TYPES[extension] || "application/octet-stream"

      set_game_frame_headers if content_type == "text/html"

      send_file(full_path, type: content_type, disposition: "inline")
    end

    def set_game_frame_headers
      response.headers.delete("X-Frame-Options")
      response.headers[
        "Content-Security-Policy"
      ] = "default-src 'none'; script-src 'self' 'unsafe-inline' 'unsafe-eval' 'wasm-unsafe-eval' blob:; worker-src 'self' blob:; child-src 'self' blob:; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; media-src 'self' blob: data:; connect-src 'self'; font-src 'self' data:;"
    end
  end
end
