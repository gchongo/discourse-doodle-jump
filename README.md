# discourse-doodle-jump

Doodle Jump mini-game page for Discourse with a standalone all-time leaderboard.

## Features

- Playable at `/game/doodle-jump` on desktop and mobile
- Guests can play; only logged-in users appear on the leaderboard
- Configurable all-time top N (`doodle_jump_leaderboard_size`, 5–50)
- Page layout matches Discourse static pages (`container` + `body-page`)
- Game based on [takosenpai2687/doodle-jump](https://github.com/takosenpai2687/doodle-jump) (MIT)

## Installation

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - rm -rf discourse-doodle-jump
          - git clone https://github.com/howhy-day/discourse-doodle-jump.git
```

```bash
./launcher rebuild app
```

Enable `doodle_jump_enabled` in admin site settings.

## Settings

| Setting | Default | Description |
|---|---|---|
| `doodle_jump_enabled` | `false` | Master switch |
| `doodle_jump_leaderboard_size` | `10` | All-time leaderboard size (5–50) |

## Game credits

- Game code: [takosenpai2687/doodle-jump](https://github.com/takosenpai2687/doodle-jump)
- Sound assets: [The Sounds Resource](https://www.sounds-resource.com/mobile/doodlejump/sound/1636/)

## License

Plugin code: follow your Discourse deployment license.

Bundled game: MIT (see `public/game/LICENSE`).
