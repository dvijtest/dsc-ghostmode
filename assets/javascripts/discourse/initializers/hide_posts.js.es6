import { withPluginApi } from "discourse/lib/plugin-api";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

function registeraddPostMenuButtons(api) {
  api.addPostMenuButton({
    id: "hideposts",
    icon() {
      const isHidden = this.get("posts.hide_posts");
      return isHidden ? "far-eye" : "far-eye-slash";
    },
    priority: 250,
    title() {
      const isHidden = this.get("posts.hide_posts");
      return `hide_posts.button.${isHidden ? "show_posts" : "hide_posts"}.help`;
    },
    label() {
      const isHidden = this.get("posts.hide_posts");
      return `hide_posts.button.${isHidden ? "show_posts" : "hide_posts"}.button`;
    },
    action() {
      if (!this.get("posts.user_id")) {
        return;
      }

      var action;
      if (this.get("posts.hide_posts")) {
        action = 'disable';
      } else {
        action = 'enable';
      }

      return ajax('/hide_posts/' + action + '.json', {
        type: "PUT",
        data: { id: this.get("posts.id") }
      })
      .then(result => { 
        this.set("posts.hide_posts", result.ghostmode_enabled);
      })
      .catch(popupAjaxError);
    },
    dropdown() {
      return this.site.mobileView;
    },
    classNames: ["hide-posts"],
    dependentKeys: [
      "posts.hide_posts"
    ],
    displayed() {
      //const topic_owner_id = this.get("posts.user_id") ;
      //return this.currentUser && ((this.currentUser.id == topic_owner_id) || this.currentUser.staff);
      return this.currentUser.staff;
    }
  });
}

export default {
  name: "hide_posts",
  initialize(container) {
    const siteSettings = container.lookup("site-settings:main");
    if (!siteSettings.ghostmode_enabled) {
      return;
    }

    withPluginApi("0.8.28", api => registeraddPostMenuButtons(api, container));
  }
};