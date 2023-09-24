import { ByondCall } from '~/common/types';
import { useHeaderSlice } from '~/stores/header';

const CLIENT_DATA_LIMIT = 5;
const CLIENT_DATA_KEY = 'parachat-client-data';

let pingStart = 0;
let clientData = [];

export const ehjaxCallback: ByondCall = topic => {
  if (topic === 'pang') {
    initiatePing();
  } else if (topic === 'pong') {
    const ping = Math.ceil((Date.now() - pingStart) / 2);
    useHeaderSlice.setState({ ping });
  } else {
    try {
      const payload = JSON.parse(topic);
      if (payload && payload.clientData) {
        handleClientData(payload.clientData);
      }
    } catch (e) {
      /* empty */
    }
  }
};

export const initiatePing = () => {
  pingStart = Date.now();
  window.location.href = '?_src_=chat&proc=ping';
};

export const initClientData = () => {
  const clientDataCookie = getClientDataCookie();
  if (clientDataCookie.length) {
    try {
      clientData = JSON.parse(clientDataCookie) || [];
      window.localStorage.setItem(CLIENT_DATA_KEY, JSON.stringify(clientData));
    } catch (e) {
      /* empty */
    }
    const d = new Date();
    d.setTime(d.getTime() + 365 * 24 * 60 * 60 * 1000);
    const expires = 'expires=' + d.toUTCString();
    document.cookie = 'paradise-connData=; ' + expires + '; path=/';
    return;
  }

  try {
    clientData = JSON.parse(window.localStorage.getItem(CLIENT_DATA_KEY)) || [];
  } catch (e) {
    /* empty */
  }
};

const getClientDataCookie = () => {
  const name = 'paradise-connData=';
  const ca = document.cookie.split(';');
  for (let i = 0; i < ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) === 0) {
      return decodeURIComponent(c.substring(name.length, c.length));
    }
  }
  return '';
};

const handleClientData = payload => {
  const { ckey, ip, compid } = payload;
  if (!ckey || !ip || !compid) {
    return;
  }

  let data = 'none';
  if (clientData.length) {
    data = JSON.stringify({ connData: clientData });
  }

  window.location.href =
    '?_src_=chat&proc=analyzeClientData&param[cookie]=' + data;

  if (
    clientData.some(
      saved => saved.ckey === ckey && saved.ip === ip && saved.compid === compid
    )
  ) {
    return;
  }

  while (clientData.length >= CLIENT_DATA_LIMIT) {
    clientData.shift();
  }
  clientData.push({ ckey, ip, compid });
  window.localStorage.setItem(CLIENT_DATA_KEY, JSON.stringify(clientData));
};
