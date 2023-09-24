import { render } from 'react-dom';
import { playAudio } from '~/byondcalls/admin';
import { codewords, codewordsClear } from '~/byondcalls/codewords';
import { ehjaxCallback, initClientData } from '~/byondcalls/ehjax';
import { output } from '~/byondcalls/output';
import { reboot, rebootFinished } from '~/byondcalls/reboot';
import App from '~/components/App';
import { useMessageSlice } from './stores/message';

const setupApp = () => {
  // Set up debug console
  window.debugs = [];
  console.log = text => window.debugs.push(text);

  // Set up byond calls so we can receive them
  window.codewords = codewords;
  window.codewordsClear = codewordsClear;
  window.ehjaxCallback = ehjaxCallback;
  window.output = output;
  window.playAudio = playAudio;
  window.reboot = reboot;
  window.rebootFinished = rebootFinished;

  // Initial render and subscribe to new messages
  render(<App />, document.getElementById('root'));
  useMessageSlice.subscribe(() =>
    render(<App />, document.getElementById('root'))
  );

  initClientData();
  window.location.href =
    '?_src_=chat&proc=doneLoading&param[chatType]=parachat';
};

setupApp();
