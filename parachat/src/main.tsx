import { render } from 'react-dom';
import { playAudio } from '~/byondcalls/admin';
import { codewords, codewordsClear } from '~/byondcalls/codewords';
import { output } from '~/byondcalls/output';
import { reboot, rebootFinished } from '~/byondcalls/reboot';
import { useMessageSlice } from '~/common/store';
import App from '~/components/App';

const setupApp = () => {
  // Set up debug console
  window.debugs = [];
  console.log = text => window.debugs.push(text);

  // Set up byond calls so we can receive them
  window.codewords = codewords;
  window.codewordsClear = codewordsClear;
  window.ehjaxCallback = () => {};
  window.output = output;
  window.playAudio = playAudio;
  window.reboot = reboot;
  window.rebootFinished = rebootFinished;

  // Initial render and subscribe to new messages
  render(<App />, document.getElementById('root'));
  useMessageSlice.subscribe(() =>
    render(<App />, document.getElementById('root'))
  );
};

setupApp();
