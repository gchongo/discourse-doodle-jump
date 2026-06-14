import Component from "@glimmer/component";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import { i18n } from "discourse-i18n";
import DButton from "discourse/ui-kit/d-button";
import dIcon from "discourse/ui-kit/helpers/d-icon";

export default class DoodleJumpGuestNotice extends Component {
  @action
  showLogin() {
    getOwner(this).lookup("route:application").send("showLogin");
  }

  @action
  showCreateAccount() {
    getOwner(this).lookup("route:application").send("showCreateAccount");
  }

  <template>
    <div class="doodle-jump-guest-notice">
      <div class="doodle-jump-guest-notice__icon">
        {{dIcon "gamepad"}}
      </div>
      <p class="doodle-jump-guest-notice__message">
        {{i18n "discourse_doodle_jump.guest_notice"}}
      </p>
      <div class="doodle-jump-guest-notice__actions">
        <DButton
          @label="discourse_doodle_jump.login_to_rank"
          @action={{this.showLogin}}
          class="btn-primary btn-small"
        />
        <DButton
          @label="discourse_doodle_jump.signup_to_rank"
          @action={{this.showCreateAccount}}
          class="btn-default btn-small"
        />
      </div>
    </div>
  </template>
}
