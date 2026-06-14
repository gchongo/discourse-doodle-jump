# frozen_string_literal: true

module ::DiscourseDoodleJump
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscourseDoodleJump
  end
end
