var $ = document.querySelector.bind(document);
var input;
var submitButton;
var optionsMap = {};

function updateTopic() {
  if (!input || !submitButton) {
    return;
  }

  var hrefList = submitButton.getAttribute('href').split(';');
  // Topic must come last in the submit button for this to work
  hrefList = hrefList.slice(0, hrefList.length - 1);
  hrefList.push(optionsMap[input.value] ? 'submit=' + optionsMap[input.value] : '');
  submitButton.setAttribute('href', hrefList.join(';'));
}

function clean(name) {
  // \improper shows up as 2 characters outside of ascii range
  if (name.charCodeAt(0) > 127) {
    return name.slice(2);
  }
  return name;
}

function setElements() {
  input = $('#input');
  submitButton = $('#submit-button');
  var choices = $('#choices');

  if (!input || !submitButton || !choices) {
    return;
  }


  for (var i = 0; i < choices.options.length; i++) {
    var name = choices.options[i].value;
    var cleaned = clean(name);
    optionsMap[cleaned] = name;
    choices.options[i].value = cleaned;
  }

  input.addEventListener('keyup', function(event) {
    if (event.key !== 'Enter') {
      return;
    }

    if (Object.keys(optionsMap).indexOf(input.value) === -1) {
      // Byond doesn't let you to use enter to select
      // so we need to prevent unintended submissions
      return
    }

    submitButton.click();
    event.preventDefault();
  });

  input.focus();
}

window.onload = setElements;
