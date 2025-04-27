/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import fs from 'node:fs';
import path from 'node:path';

import { globSync } from 'glob';

export const resolvePath = path.resolve;

/** Combines path.resolve with glob patterns. */
export function resolveGlob(...sections) {
  /** @type {string[]} */
  const unsafePaths = globSync(path.resolve(...sections), {
    strict: false,
    silent: true,
    windowsPathsNoEscape: true,
  });

  /** @type {string[]} */
  const safePaths = [];

  for (let path of unsafePaths) {
    try {
      fs.statSync(path);
      safePaths.push(path);
    } catch {}
  }

  return safePaths;
}
