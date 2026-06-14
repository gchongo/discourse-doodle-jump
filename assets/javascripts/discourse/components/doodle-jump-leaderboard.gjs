import Component from "@glimmer/component";
import { i18n } from "discourse-i18n";
import dAvatar from "discourse/ui-kit/helpers/d-avatar";
import { eq } from "discourse/truth-helpers";

export default class DoodleJumpLeaderboard extends Component {
  get entries() {
    return this.args.data?.leaderboard || [];
  }

  <template>
    <section class="doodle-jump-leaderboard">
      <h2>{{i18n "discourse_doodle_jump.leaderboard_title"}}</h2>

      {{#if @loading}}
        <p class="doodle-jump-leaderboard__loading">{{i18n "discourse_doodle_jump.loading"}}</p>
      {{else if (eq this.entries.length 0)}}
        <p class="doodle-jump-leaderboard__empty">{{i18n "discourse_doodle_jump.leaderboard_empty"}}</p>
      {{else}}
        <table class="doodle-jump-leaderboard__table">
          <thead>
            <tr>
              <th>{{i18n "discourse_doodle_jump.rank"}}</th>
              <th>{{i18n "discourse_doodle_jump.player"}}</th>
              <th>{{i18n "discourse_doodle_jump.score"}}</th>
            </tr>
          </thead>
          <tbody>
            {{#each this.entries as |entry|}}
              <tr>
                <td class="doodle-jump-leaderboard__rank">{{entry.rank}}</td>
                <td class="doodle-jump-leaderboard__player">
                  {{dAvatar entry imageSize="small"}}
                  <span class="doodle-jump-leaderboard__username">@{{entry.username}}</span>
                </td>
                <td class="doodle-jump-leaderboard__score">{{entry.score}}</td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      {{/if}}
    </section>
  </template>
}
