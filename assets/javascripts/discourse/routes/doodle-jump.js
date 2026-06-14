import Route from "@ember/routing/route";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

export default class DoodleJumpRoute extends Route {
  @service siteSettings;
  @service router;

  beforeModel() {
    if (!this.siteSettings.doodle_jump_enabled) {
      this.router.replaceWith("discovery.latest");
    }
  }

  model() {
    return { enabled: true };
  }

  titleToken() {
    return i18n("discourse_doodle_jump.title");
  }
}
