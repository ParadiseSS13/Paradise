/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { exec } from 'node:child_process';
import os from 'node:os';
import { promisify } from 'node:util';

import axios, { isAxiosError } from 'axios';

import { createLogger } from './logging.js';

const logger = createLogger('dreamseeker');

const instanceByPid = new Map();

export class DreamSeeker {
  /**
   * @param {number} pid
   * @param {string} addr
   */
  constructor(pid, addr) {
    /** @type {number} */
    this.pid = pid;
    /** @type {string} */
    this.addr = addr;
    /** @type {import('axios').AxiosInstance} */
    this.client = axios.create({
      baseURL: `http://${addr}`,
    });
  }

  /**
   * @param {Object} params
   * @returns {Promise<Response>}
   */
  topic(params = {}) {
    const query = Object.keys(params)
      .map((key) => encodeURIComponent(key) + '=' + encodeURIComponent(params[key]))
      .join('&');
    logger.log(`topic call at ${this.client.defaults.baseURL}/dummy.htm?${query}`);
    return this.client.get('/dummy.htm?' + query).catch((e) => {
      if (isAxiosError(e) && e.code === 'ECONNREFUSED') {
        // Client exited, remove from list
        instanceByPid.delete(this.pid);
        logger.log(`client disconnected`);
      } else {
        throw e;
      }
    });
  }

  /**
   * @param {number[]} pids
   * @returns {Promise<DreamSeeker[]>}
   */
  static async getInstancesByPids(pids) {
    /** @type {DreamSeeker[]} */
    const instances = [];
    /** @type {number[]} */
    const pidsToResolve = [];

    for (let pid of pids) {
      const instance = instanceByPid.get(pid);
      if (instance) {
        instances.push(instance);
      } else {
        pidsToResolve.push(pid);
      }
    }

    if (pidsToResolve.length === 0) {
      return instances;
    }

    try {
      const entries =
        os.platform() === 'win32' ? await getWindowsEntries(pidsToResolve) : await getLinuxEntries(pidsToResolve);

      const len = entries.length;
      logger.log('found', len, plural('instance', len));
      for (let entry of entries) {
        const { pid, addr } = entry;
        const instance = new DreamSeeker(pid, addr);
        instances.push(instance);
        instanceByPid.set(pid, instance);
      }
    } catch (err) {
      if (err.code === 'ERR_CHILD_PROCESS_STDIO_MAXBUFFER') {
        logger.error(err.message, err.code);
      } else {
        logger.error(err);
      }
      return [];
    }
    return instances;
  }
}

async function getWindowsEntries(pidsToResolve) {
  const { stdout } = await run('netstat -ano | findstr TCP | findstr 0.0.0.0:0');

  // Line format:
  // proto addr mask mode pid
  const entries = [];
  const lines = stdout.split('\r\n');

  for (let line of lines) {
    const words = line.match(/\S+/g);
    if (!words || words.length === 0) {
      continue;
    }
    const entry = {
      addr: words[1],
      pid: parseInt(words[4], 10),
    };
    if (pidsToResolve.includes(entry.pid)) {
      entries.push(entry);
    }
  }
  return entries;
}

async function getLinuxEntries(pidsToResolve) {
  const { stdout } = await run('ss -tlnp');

  const addrs = [];

  for (const line of stdout.split('\n')) {
    if (!line.includes('wineserver') || !line.includes('127.0.0.1')) continue;

    const parts = line.trim().split(/\s+/);
    const addr = parts[3];

    addrs.push(addr);
  }

  const entries = (
    await Promise.all(
      addrs.map(async (addr) => {
        try {
          const result = await axios.get(`http://${addr}/pid.htm`, { timeout: 300 });

          const pid = parseInt(result.data, 10);
          return Number.isNaN(pid) ? null : { pid, addr };
        } catch {
          return null;
        }
      })
    )
  ).filter(Boolean);

  return entries;
}

async function run(command) {
  return promisify(exec)(command, {
    maxBuffer: 1024 * 1024,
  });
}

function plural(word, n) {
  return n !== 1 ? word + 's' : word;
}
