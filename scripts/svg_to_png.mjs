import { existsSync } from 'node:fs';
import sharp from 'sharp';

const src = 'assets/images/svg/logo.svg';
const dst2048 = 'assets/images/png/icon-2048.png';
const dst1024 = 'assets/images/png/icon-1024.png';

if (!existsSync(src)) {
  console.error(`Missing ${src}`);
  process.exit(1);
}

try {
  await sharp(src, { density: 400 })
    .resize(2048, 2048, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png({ compressionLevel: 9 })
    .toFile(dst2048);
  console.error(`Saved ${dst2048} (2048x2048 from SVG)`);

  await sharp(src, { density: 400 })
    .resize(1024, 1024, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png({ compressionLevel: 9 })
    .toFile(dst1024);
  console.error(`Saved ${dst1024} (1024x1024 from SVG, high quality)`);
} catch (e) {
  console.error(`sharp SVG rasterize failed: ${e.message}`);
  console.error('Fallback: keeping existing PNG source');
  if (!existsSync('assets/images/png/icon-1024.png')) process.exit(1);
}
