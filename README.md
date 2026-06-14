# discourse-doodle-jump

Discourse plugin: Doodle Jump mini-game at `/game/doodle-jump` with a standalone all-time leaderboard.

## Features (v0.1.2)

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

Always include `rm -rf discourse-doodle-jump` before clone. Without it, stale game files can remain on disk and cause errors such as `soundFormats is not defined` or Google Fonts CSP warnings.

Rebuild:

```bash
cd /var/discourse
./launcher rebuild app
```

Enable **`doodle_jump_enabled`** in admin → Settings → Plugins (default is off; when off, the Ember route is not loaded and `/game/doodle-jump` shows a 404).

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

Scroll up in the rebuild log for the first `StandardError` / `PG::` line.

A common mistake is a **future migration timestamp**. Discourse rejects any migration newer than the current UTC time, for example:

```text
Migration 20260614100000 is timestamped in the future
```

Plugin migrations must use a timestamp that is already in the past at rebuild time. This repo uses `20260614002000` (after `discourse-quiz`, before noon UTC).

To rerun migrations and see the full error:

```bash
./launcher enter app
su discourse -c "cd /var/www/discourse && bundle exec rake db:migrate --trace"
```

**Page shows 404 or redirects home**

1. Check that **`doodle_jump_enabled`** is on (required — plugin JS and the Ember route are only loaded when enabled).
2. Rebuild completed without errors and the plugin is present under `plugins/discourse-doodle-jump`.
3. Hard-refresh the browser (Ctrl+F5) after enabling the setting.

**Game iframe is blank, stuck on "Loading...", or shows CSP errors**

The game iframe uses a relaxed CSP (including `blob:` workers). Audio is disabled in the embedded version because `p5.sound` Web Audio workers conflict with strict site CSP; gameplay is unaffected.

Pull the latest plugin, rebuild, and hard-refresh. Ignore Cloudflare Insights script warnings in the console.

**`soundFormats is not defined` or Google Fonts CSP errors after rebuild**

The origin may already serve fixed files, but **Cloudflare can keep an old cached `index.js` for up to 4 hours** (`Cf-Cache-Status: HIT`). Game assets in `index.html` use `?v=` query strings to bust that cache; bump the version in `index.html` and `doodle-jump-page.gjs` if needed.

1. Rebuild with a clean clone (`rm -rf discourse-doodle-jump` before `git clone`).
2. In Cloudflare → **Caching → Purge Cache** → purge URLs:
   - `/game/doodle-jump/play/js/index.js`
   - `/game/doodle-jump/play/css/style.css`
   Or use **Purge Everything** once after deploy.
3. Hard-refresh or open in a private window. Check `/game/doodle-jump/play/js/index.js?v=3` — it must **not** contain `soundFormats` or `userStartAudio`.

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
