import bodyClass from "discourse/helpers/body-class";
import DoodleJumpPage from "../components/doodle-jump-page";

export default <template>
  {{bodyClass "doodle-jump"}}

  <section class="container">
    <div class="contents clearfix body-page">
      <DoodleJumpPage />
    </div>
  </section>
</template>
