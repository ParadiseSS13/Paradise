var uid;

function allowDrop(ev) {
  ev.preventDefault();
}

function drag(ev) {
  var index = ev.target.getAttribute('index');
  if (index) {
    ev.dataTransfer.setData('text', index);
  }
}

function drop(ev) {
  ev.preventDefault();
  var data = ev.dataTransfer.getData('text');
  if (data && ev.target.getAttribute('index')) {
    window.location = '?src=' + uid + ';' + 'cut=' + data + ';' + 'insert=' + ev.target.getAttribute('index');
  }
}

function setUid() {
  uid = document.getElementById('choices').getAttribute('uid');
}

window.onload = setUid;
