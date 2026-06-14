# frozen_string_literal: true

DiscourseDoodleJump::Engine.routes.draw do
  get "/scores" => "scores#index"
  post "/scores" => "scores#create"

  get "/play" => "play#index"
  get "/play/" => "play#index"
  get "/play/*path" => "play#show"
end

Discourse::Application.routes.draw { mount ::DiscourseDoodleJump::Engine, at: "/game/doodle-jump" }
