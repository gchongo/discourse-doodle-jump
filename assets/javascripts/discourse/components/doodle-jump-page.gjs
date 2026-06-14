import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import DoodleJumpLeaderboard from "./doodle-jump-leaderboard";
import DoodleJumpGuestNotice from "./doodle-jump-guest-notice";

export default class DoodleJumpPage extends Component {
  @service currentUser;
  @service toasts;

  @tracked leaderboardData = null;
  @tracked loadingLeaderboard = true;

  gameUrl = "/game/doodle-jump/play/";

  constructor() {
    super(...arguments);
    this.loadLeaderboard();
  }

  handleMessage = (event) => {
    const data = event?.data;
    if (!data || data.type !== "doodle-jump:score") {
      return;
    }

    const score = Number.parseInt(data.score, 10);
    if (!Number.isFinite(score) || score <= 0) {
      return;
    }

    if (!this.currentUser) {
      return;
    }

    this.submitScore(score);
  };

  listenForScore = modifier(() => {
    window.addEventListener("message", this.handleMessage);
    return () => {
      window.removeEventListener("message", this.handleMessage);
    };
  });

  @action
  async loadLeaderboard() {
    this.loadingLeaderboard = true;

    try {
      this.leaderboardData = await ajax("/game/doodle-jump/scores");
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.loadingLeaderboard = false;
    }
  }

  @action
  async submitScore(score) {
    try {
      const result = await ajax("/game/doodle-jump/scores", {
        type: "POST",
        data: { score },
      });

      if (result.updated) {
        this.toasts.success({
          body: i18n("discourse_doodle_jump.new_record_toast"),
        });
      }

      await this.loadLeaderboard();
    } catch (error) {
      popupAjaxError(error);
    }
  }

  <template>
    <div class="doodle-jump-page" {{this.listenForScore}}>
      <header class="doodle-jump-page__header">
        <h1>{{i18n "discourse_doodle_jump.title"}}</h1>
        <p class="doodle-jump-page__intro">{{i18n "discourse_doodle_jump.intro"}}</p>
        <ul class="doodle-jump-page__help">
          <li>{{i18n "discourse_doodle_jump.controls_desktop"}}</li>
          <li>{{i18n "discourse_doodle_jump.controls_mobile"}}</li>
        </ul>
      </header>

      <div class="doodle-jump-page__game-shell">
        <iframe
          class="doodle-jump-page__frame"
          src={{this.gameUrl}}
          title={{i18n "discourse_doodle_jump.title"}}
          loading="lazy"
          allow="autoplay"
        ></iframe>
      </div>

      {{#if this.currentUser}}
        {{#if this.leaderboardData}}
          {{#if this.leaderboardData.personal}}
            <p class="doodle-jump-page__personal">
              {{i18n
                "discourse_doodle_jump.personal_best"
                rank=this.leaderboardData.personal.rank
                score=this.leaderboardData.personal.score
              }}
            </p>
          {{/if}}
        {{/if}}
      {{else}}
        <DoodleJumpGuestNotice />
      {{/if}}

      <DoodleJumpLeaderboard
        @data={{this.leaderboardData}}
        @loading={{this.loadingLeaderboard}}
      />
    </div>
  </template>
}
