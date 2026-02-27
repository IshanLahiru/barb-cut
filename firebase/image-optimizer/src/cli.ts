import * as fs from "fs";
import * as path from "path";
import sharp from "sharp";
import { glob } from "glob";

// ── Types ────────────────────────────────────────────────────────────

interface SizeVariant {
  name: string;
  width: number;
}

interface PngOptions {
  compressionLevel: number;
}

interface Config {
  sourceDir: string;
  outputDir: string;
  sizes: SizeVariant[];
  png: PngOptions;
  include: string[];
  exclude: string[];
}

// ── Config loading ───────────────────────────────────────────────────

function loadConfig(configPath: string): Config {
  if (!fs.existsSync(configPath)) {
    throw new Error(`Config file not found: ${configPath}`);
  }

  const raw = JSON.parse(fs.readFileSync(configPath, "utf-8"));

  if (!raw.sourceDir || typeof raw.sourceDir !== "string") {
    throw new Error("Config: 'sourceDir' is required and must be a string");
  }
  if (!raw.outputDir || typeof raw.outputDir !== "string") {
    throw new Error("Config: 'outputDir' is required and must be a string");
  }
  if (!Array.isArray(raw.sizes) || raw.sizes.length === 0) {
    throw new Error("Config: 'sizes' must be a non-empty array");
  }

  for (const s of raw.sizes) {
    if (!s.name || typeof s.width !== "number" || s.width <= 0) {
      throw new Error(
        `Config: each size must have a 'name' and a positive 'width'. Got: ${JSON.stringify(s)}`
      );
    }
  }

  return {
    sourceDir: raw.sourceDir,
    outputDir: raw.outputDir,
    sizes: raw.sizes,
    png: {
      compressionLevel: raw.png?.compressionLevel ?? 9,
    },
    include: raw.include ?? ["**/*.png"],
    exclude: raw.exclude ?? [],
  };
}

// ── File discovery ───────────────────────────────────────────────────

async function findSourceFiles(config: Config): Promise<string[]> {
  const patterns = config.include.length > 0 ? config.include : ["**/*.png"];
  const allFiles: string[] = [];

  for (const pattern of patterns) {
    const matches = await glob(pattern, {
      cwd: config.sourceDir,
      nodir: true,
      ignore: config.exclude,
    });
    allFiles.push(...matches);
  }

  // Deduplicate
  return [...new Set(allFiles)].sort();
}

// ── Output path ──────────────────────────────────────────────────────

function taggedOutputPath(outputDir: string, relFile: string, sizeName: string): string {
  const dir = path.join(outputDir, path.dirname(relFile));
  const ext = path.extname(relFile);
  const base = path.basename(relFile, ext);
  return path.join(dir, `${base}_${sizeName}${ext}`);
}

// ── Freshness check ──────────────────────────────────────────────────

function isStale(srcPath: string, destPath: string): boolean {
  if (!fs.existsSync(destPath)) return true;
  const srcStat = fs.statSync(srcPath);
  const destStat = fs.statSync(destPath);
  return srcStat.mtimeMs > destStat.mtimeMs;
}

// ── Image processing ─────────────────────────────────────────────────

async function optimizeImage(
  srcAbsolute: string,
  destAbsolute: string,
  size: SizeVariant,
  pngOpts: PngOptions
): Promise<boolean> {
  const metadata = await sharp(srcAbsolute).metadata();
  const srcWidth = metadata.width ?? 0;

  const needsResize = srcWidth > size.width;

  fs.mkdirSync(path.dirname(destAbsolute), { recursive: true });

  let pipeline = sharp(srcAbsolute);

  if (needsResize) {
    pipeline = pipeline.resize({
      width: size.width,
      kernel: sharp.kernel.lanczos3,
      withoutEnlargement: true,
    });
  }

  await pipeline
    .png({
      compressionLevel: pngOpts.compressionLevel,
      palette: false,
    })
    .toFile(destAbsolute);

  return true;
}

// ── CLI entry point ──────────────────────────────────────────────────

async function main() {
  const args = process.argv.slice(2);
  const force = args.includes("--force");

  let configPath = "config.json";
  const configIdx = args.indexOf("--config");
  if (configIdx !== -1 && args[configIdx + 1]) {
    configPath = args[configIdx + 1];
  }

  const resolvedConfigPath = path.resolve(configPath);
  console.log(`\nImage Optimizer`);
  console.log(`───────────────────────────────────`);
  console.log(`Config : ${resolvedConfigPath}`);
  console.log(`Force  : ${force}`);

  const config = loadConfig(resolvedConfigPath);

  const absSource = path.resolve(config.sourceDir);
  const absOutput = path.resolve(config.outputDir);

  console.log(`Source : ${absSource}`);
  console.log(`Output : ${absOutput}`);
  console.log(`Sizes  : ${config.sizes.map((s) => `${s.name} (${s.width}px)`).join(", ")}`);
  console.log(`───────────────────────────────────\n`);

  if (!fs.existsSync(absSource)) {
    console.error(`Source directory does not exist: ${absSource}`);
    process.exit(1);
  }

  const files = await findSourceFiles(config);

  if (files.length === 0) {
    console.log("No PNG files found in source directory.");
    return;
  }

  console.log(`Found ${files.length} PNG file(s).\n`);

  const startTime = Date.now();
  let processed = 0;
  let skipped = 0;

  for (const relFile of files) {
    const srcAbsolute = path.join(absSource, relFile);

    for (const size of config.sizes) {
      const destAbsolute = taggedOutputPath(absOutput, relFile, size.name);

      if (!force && !isStale(srcAbsolute, destAbsolute)) {
        skipped++;
        continue;
      }

      try {
        await optimizeImage(srcAbsolute, destAbsolute, size, config.png);
        const srcSize = fs.statSync(srcAbsolute).size;
        const destSize = fs.statSync(destAbsolute).size;
        const ratio = ((1 - destSize / srcSize) * 100).toFixed(1);
        console.log(
          `  ✓ ${size.name.padEnd(8)} ${relFile}  (${formatBytes(srcSize)} → ${formatBytes(destSize)}, ${ratio}% smaller)`
        );
        processed++;
      } catch (err: any) {
        console.error(`  ✗ ${size.name.padEnd(8)} ${relFile}  ERROR: ${err.message}`);
      }
    }
  }

  const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);

  console.log(`\n───────────────────────────────────`);
  console.log(`Done in ${elapsed}s`);
  console.log(`  Processed : ${processed}`);
  console.log(`  Skipped   : ${skipped} (up-to-date)`);
  console.log(`  Total     : ${processed + skipped}\n`);
}

function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
