/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { exec } from 'node:child_process';
import { promisify } from 'node:util';
import fs from "fs/promises";
import os from 'node:os';

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
      const entries = os.platform() === 'win32'
        ? await getWindowsEntries(pidsToResolve)
        : await getLinuxEntries(pidsToResolve);

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
  const { stdout } = await run('netstat -ano | findstr TCP | findstr 0.0.0.0:0')

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
  
  const wineServers = new Map();

  for (const line of stdout.split('\n')) {
    if (!line.includes('wineserver') || !line.includes('127.0.0.1')) continue;

    const parts = line.trim().split(/\s+/);
    const addr = parts[3]

    const pidMatch = line.match(/pid=(\d+)/);
    if (!pidMatch) continue;

    const linuxPid = pidMatch[1];
    if (!wineServers.has(linuxPid)) wineServers.set(linuxPid, [])
    wineServers.get(linuxPid).push(addr);
  }

  const entries = [];

  for (const [linuxPid, addrs] of wineServers) {
    try {
      const env = await fs.readFile(`/proc/${linuxPid}/environ`, 'utf8');
      const prefix = env.split('\0').find(l => l.startsWith("WINEPREFIX"))?.split('=')[1];
      if(!prefix) continue;

      const { stdout: winedbgOut } = await run(`WINEPREFIX=${prefix} winedbg --command "info proc"`);
      const winPids = winedbgOut.split('\n');

      for (const line of winPids) {
        if(!line.includes('dreamseeker.exe')) continue;

        const parts = line.trim().split(/\s+/);
        const winPid = parseInt(parts[0], 16)

        if(pidsToResolve.includes(winPid)) {
          for (const addr of addrs) {
            entries.push({addr, pid: winPid})
          }
        }
      }
    } catch (err) {
      logger.log(err);
      continue;
    }
  }

  return entries
}

async function run(command) {
  return promisify(exec)(command, {
    maxBuffer: 1024 * 1024,
  });
}

function plural(word, n) {
  return n !== 1 ? word + 's' : word;
}
