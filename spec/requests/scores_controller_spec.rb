# frozen_string_literal: true

RSpec.describe DiscourseDoodleJump::ScoresController do
  fab!(:user) { Fabricate(:user) }
  fab!(:other_user) { Fabricate(:user) }

  before { SiteSetting.doodle_jump_enabled = true }

  describe "GET /game/doodle-jump/scores.json" do
    it "returns an empty leaderboard by default" do
      get "/game/doodle-jump/scores.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["leaderboard"]).to eq([])
      expect(response.parsed_body["personal"]).to be_nil
    end

    it "returns personal stats for signed-in users" do
      DiscourseDoodleJump::Score.create!(user_id: user.id, score: 1200)

      sign_in(user)
      get "/game/doodle-jump/scores.json"

      expect(response.parsed_body["personal"]["score"]).to eq(1200)
      expect(response.parsed_body["personal"]["rank"]).to eq(1)
    end

    it "respects the configured leaderboard size" do
      SiteSetting.doodle_jump_leaderboard_size = 5

      6.times do |index|
        member = Fabricate(:user)
        DiscourseDoodleJump::Score.create!(user_id: member.id, score: 1000 + index)
      end

      get "/game/doodle-jump/scores.json"

      expect(response.parsed_body["leaderboard"].length).to eq(5)
    end

    it "is hidden when the plugin is disabled" do
      SiteSetting.doodle_jump_enabled = false

      get "/game/doodle-jump/scores.json"
      expect(response.status).to eq(404)
    end
  end

  describe "POST /game/doodle-jump/scores.json" do
    it "requires login" do
      post "/game/doodle-jump/scores.json", params: { score: 100 }

      expect(response.status).to eq(403)
    end

    it "stores the user's best score" do
      sign_in(user)

      post "/game/doodle-jump/scores.json", params: { score: 500 }
      expect(response.status).to eq(200)
      expect(response.parsed_body["updated"]).to eq(true)
      expect(response.parsed_body["personal"]["score"]).to eq(500)

      post "/game/doodle-jump/scores.json", params: { score: 300 }
      expect(response.parsed_body["updated"]).to eq(false)
      expect(DiscourseDoodleJump::Score.find_by(user_id: user.id).score).to eq(500)

      post "/game/doodle-jump/scores.json", params: { score: 900 }
      expect(response.parsed_body["updated"]).to eq(true)
      expect(DiscourseDoodleJump::Score.find_by(user_id: user.id).score).to eq(900)
    end

    it "rejects invalid scores" do
      sign_in(user)

      post "/game/doodle-jump/scores.json", params: { score: 0 }
      expect(response.status).to eq(400)
    end
  end

  describe "GET /game/doodle-jump/play/" do
    it "serves the game shell" do
      get "/game/doodle-jump/play/"

      expect(response.status).to eq(200)
      expect(response.body).to include("Doodle Jump")
      expect(response.headers["Content-Security-Policy"]).to include("script-src 'self'")
    end

    it "serves game assets with the correct content type" do
      get "/game/doodle-jump/play/css/style.css"

      expect(response.status).to eq(200)
      expect(response.media_type).to eq("text/css")
    end
  end
end
