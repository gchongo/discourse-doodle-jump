# frozen_string_literal: true

module DiscourseDoodleJump
  class PageController < ::ApplicationController
    requires_plugin DiscourseDoodleJump::PLUGIN_NAME

    def show
      raise ApplicationController::RenderEmpty
    end
  end
end
