import { useBackend } from '../../backend';
import { PowerMonitorMainContent } from '../PowerMonitor';

export const pda_power = (props) => {
  const { act, data } = useBackend();

  return <PowerMonitorMainContent />;
};
