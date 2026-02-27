# Image Optimizer

Local CLI tool that resizes PNG images into app-optimized size variants using [sharp](https://sharp.pixelplumbing.com/). This is **local tooling only** — it is not deployed as a Cloud Function.

### Default size variants (tuned for BarbCut)

| Variant | Width | App usage |
|---|---|---|
| `thumb` | 300 px | Inline preview cards (100px @3x) |
| `card` | 600 px | Style cards, explore grid tiles (~200px @3x) |
| `hero` | 1200 px | Home/history carousels, full-screen views (~400px @3x) |

## Setup

```bash
cd firebase/image-optimizer
npm install
```

## Configuration

Copy the example config and edit as needed:

```bash
cp config.example.json config.json
```

**config.json** fields:

| Field | Description |
|---|---|
| `sourceDir` | Directory containing source PNG files (default `./input`) |
| `outputDir` | Where optimized variants are written (default `./output`) |
| `sizes` | Array of `{ name, width }` size variants to generate |
| `png.compressionLevel` | zlib compression level 0-9 (default `9`, lossless — only affects file size vs encode speed) |
| `include` | Glob patterns to match source files (default `["**/*.png"]`) |
| `exclude` | Glob patterns to skip |

Example:

```json
{
  "sourceDir": "./input",
  "outputDir": "./output",
  "sizes": [
    { "name": "thumb", "width": 300 },
    { "name": "card", "width": 600 },
    { "name": "hero", "width": 1200 }
  ],
  "png": { "compressionLevel": 9, "quality": 80 },
  "include": ["**/*.png"],
  "exclude": []
}
```

## Usage

Place source PNGs into `input/` (or wherever `sourceDir` points), then run:

```bash
npm run optimize
```

This builds the TypeScript and runs the optimizer. The size tag is appended to each filename:

```
input/                     output/
  haircut_front.png   →      haircut_front_thumb.png   (300px)
                             haircut_front_card.png    (600px)
                             haircut_front_hero.png    (1200px)
  beard_side.png      →      beard_side_thumb.png
                             beard_side_card.png
                             beard_side_hero.png
```

### Options

| Flag | Description |
|---|---|
| `--force` | Re-process all images even if the output is up-to-date |
| `--config <path>` | Use a custom config file (default `config.json`) |

```bash
# Force re-process everything
npm run optimize:force

# Use a different config
npm run optimize -- --config my-config.json
```

### Incremental builds

By default the tool skips images whose output is newer than the source. Use `--force` to override.

## Directory layout

```
image-optimizer/
  src/cli.ts          # Main optimizer script (TypeScript)
  config.example.json # Template configuration
  input/              # Drop source PNGs here
  output/             # Generated size variants (gitignored)
```
