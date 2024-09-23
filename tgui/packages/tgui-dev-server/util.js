/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import fs from 'fs';
import path from 'path';
import { globSync } from 'glob';

export const resolvePath = path.resolve;

/**
 * Combines path.resolve with glob patterns.
 */
export const resolveGlob = (...sections) => {
  const unsafePaths = globSync(path.resolve(...sections), { nodir: false, windowsPathsNoEscape: true });
  const safePaths = [];
  for (let path of unsafePaths) {
    try {
      fs.statSync(path);
      safePaths.push(path);
    } catch {}
  }
  return safePaths;
};
