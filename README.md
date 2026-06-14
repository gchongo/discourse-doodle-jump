# discourse-doodle-jump

Discourse plugin: Doodle Jump mini-game at `/game/doodle-jump` with a standalone all-time leaderboard.

## Features (v0.1.0)

- Game page at **`/game/doodle-jump`** — desktop and mobile
- **Guests can play**; only **logged-in users** appear on the leaderboard (encourages sign-up)
- **All-time top N** leaderboard (`doodle_jump_leaderboard_size`, 5–50, default 10)
- Each user keeps one **best score**; lower scores are ignored
- Page shell matches Discourse static pages (`container` + `body-page`)
- Does **not** integrate with `discourse-gamification` or site points
- Game based on [takosenpai2687/doodle-jump](https://github.com/takosenpai2687/doodle-jump) (MIT), embedded via iframe

## How to play

| Platform | Controls |
|---|---|
| Desktop | Left / right arrow keys, or A / D |
| Mobile | Touch the left or right half of the game screen |

Jump on platforms. Avoid black holes. After game over, logged-in users automatically submit their score if it is a new personal best.

## Installation

Add to `/var/discourse/containers/app.yml`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - rm -rf discourse-doodle-jump
          - git clone https://github.com/gchongo/discourse-doodle-jump.git
```

Rebuild:

```bash
cd /var/discourse
./launcher rebuild app
```

Enable **`doodle_jump_enabled`** in admin → Settings → Plugins.

Then open **`/game/doodle-jump`**.

## Settings

| Setting | Default | Description |
|---|---|---|
| `doodle_jump_enabled` | `false` | Master switch for the game page and APIs |
| `doodle_jump_leaderboard_size` | `10` | Number of players on the all-time leaderboard (5–50) |

## Leaderboard

- **GET** `/game/doodle-jump/scores.json` — public leaderboard + personal rank (if logged in)
- **POST** `/game/doodle-jump/scores.json` — logged-in users only; updates best score when higher
- Rate limit: 3 submissions per user per minute

Guests see a login / sign-up prompt below the game; their runs are not saved.

## Updating the plugin

```yaml
# in app.yml after_code, same clone URL is fine — rebuild re-clones on bootstrap
- rm -rf discourse-doodle-jump
- git clone https://github.com/gchongo/discourse-doodle-jump.git
```

```bash
./launcher rebuild app
```

To pin a version, clone a tag or commit:

```bash
git clone https://github.com/gchongo/discourse-doodle-jump.git
cd discourse-doodle-jump && git checkout v0.1.0
```

## Troubleshooting

**Bootstrap fails with `git clone ... exit 128`**

The clone URL must point to an existing public repo. Use:

```bash
git clone https://github.com/gchongo/discourse-doodle-jump.git
```

`https://github.com/howhy-day/discourse-doodle-jump` does not exist unless you create and push that repo yourself.

**Bootstrap fails at `rake db:migrate`**

Scroll up in the rebuild log for the first `StandardError` / `PG::` line — the failing migration may be this plugin or another plugin (e.g. `discourse-quiz`).

To rerun migrations and see the full error:

```bash
./launcher enter app
su discourse -c "cd /var/www/discourse && bundle exec rake db:migrate --trace"
```

If a previous failed rebuild left a half-created table, enter the container and check:

```bash
./launcher enter app
su discourse -c "cd /var/www/discourse && bundle exec rails runner \"puts ActiveRecord::Base.connection.table_exists?(:doodle_jump_scores)\""
```

Then rebuild after pulling the latest plugin commit (migrations are idempotent).

**Page shows 404 or redirects home**

Check that `doodle_jump_enabled` is on and rebuild completed without errors.

**Game loads but leaderboard stays empty**

Only logged-in users who finish a run and beat their previous best appear after the first submission.

## Development

```bash
bin/rspec plugins/discourse-doodle-jump/spec/
bin/lint plugins/discourse-doodle-jump/assets/javascripts/discourse/
```

## Credits

- Plugin: [gchongo/discourse-doodle-jump](https://github.com/gchongo/discourse-doodle-jump)
- Game: [takosenpai2687/doodle-jump](https://github.com/takosenpai2687/doodle-jump)
- Sound assets: [The Sounds Resource — Doodle Jump](https://www.sounds-resource.com/mobile/doodlejump/sound/1636/)

## License

Plugin code: follow your Discourse deployment license.

Bundled game: MIT (see `public/game/LICENSE`).
