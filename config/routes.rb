# frozen_string_literal: true

DiscourseDoodleJump::Engine.routes.draw do
  root to: "page#show"
  get "/" => "page#show"

  get "/scores" => "scores#index"
  post "/scores" => "scores#create"

  scope format: false do
    get "/play" => "play#index"
    get "/play/" => "play#index"
    get "/play/*path" => "play#show"
  end
end

Discourse::Application.routes.draw { mount ::DiscourseDoodleJump::Engine, at: "/game/doodle-jump" }
