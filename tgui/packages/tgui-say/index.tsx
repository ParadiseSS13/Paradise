import './styles/main.scss';
import { render } from 'inferno';

import { TguiSay } from './TguiSay';

document.onreadystatechange = function () {
  if (document.readyState !== 'complete') {
    Byond.sendMessage('ready_state_error');
    return;
  }

  const root = document.getElementById('react-root');
  render(<TguiSay />, root);
};
