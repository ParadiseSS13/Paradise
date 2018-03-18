function setCookie(cname, cvalue, exdays) {
  cvalue = encodeURIComponent(cvalue);
  const d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  const expires = 'expires=' + d.toUTCString();
  document.cookie = 'paradise-' + cname + '=' + cvalue + '; ' + expires;
}

function getCookie(cname) {
  const name = 'paradise-' + cname + '=';
  const ca = document.cookie.split(';');
  for (let i = 0; i < ca.length; i++) {
    const c = ca[i].trim();
    if (c.indexOf(name) === 0) {
      return decodeURIComponent(c.substring(name.length));
    }
  }
  return '';
}

export default {setCookie, getCookie};
