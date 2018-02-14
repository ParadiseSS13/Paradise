import runByond from './runByond';
import cookies from './cookies';

const clientDataLimit = 5;
const callbacks = {
  softPang: softPang,
  pang: pang,
  pong: pong,
}

function softPang() {
  return;
}

function pang(info) {
  info.pingTime = Date.now();
  runByond('?_src_=chat&proc=ping');
}

function pong(info) {
  info.pongTime = Date.now();
}

function isEmptyObject(obj) {
  return !(Object.getOwnPropertyNames(obj).length > 0)
}

function handleClientData(ckey, ip, compid, clientData) {
  //byond sends player info to here
  const currentData = {'ckey': ckey, 'ip': ip, 'compid': compid};
  if (clientData && isEmptyObject(clientData)) {
    runByond('?_src_=chat&proc=analyzeClientData&param[cookie]='+JSON.stringify({'connData': clientData}));

    for (var i = 0; i < clientData.length; i++) {
      var saved = clientData[i];
      if (currentData.ckey === saved.ckey &&
        currentData.ip === saved.ip &&
        currentData.compid === saved.compid) {
	return; //Record already exists
      }
    }

    if (clientData.length >= clientDataLimit) {
      clientData.shift();
    }
  }
  else {
    runByond('?_src_=chat&proc=analyzeClientData&param[cookie]=none');
  }

  //Update the cookie with current details
  clientData.push(currentData);
  cookies.setCookie('connData', JSON.stringify(clientData), 365);
}

function loadFirebug() {
  const firebugEl = document.createElement('script');
  firebugEl.src = 'https://getfirebug.com/firebug-lite-debug.js';
  document.body.appendChild(firebugEl);
}

export default function ehjaxHelper(data, info, clientData) {
  const callBack = callbacks[data];

  info.lastPang = Date.now();

  if (callBack) {
    callBack(info);
    return;
  }

  // Handle data instead of instruction

  try {
    data = JSON.parse(data);
  }
  catch (e) {
    return;
  }

  if (data.clientData) {
    if (!data.clientData.ckey && !data.clientData.ip && !data.clientData.compid) {

      return;
    }
    else {
      handleClientData(data.clientData.ckey,
                       data.clientData.ip,
                       data.clientData.compid,
                       clientData);
      info.cookieLoaded = true;
    }
  }
  else if (data.loadAdminCode) {
    info.admin = true;
  }
  else if (data.firebug) {
    loadFirebug();
  }
}
