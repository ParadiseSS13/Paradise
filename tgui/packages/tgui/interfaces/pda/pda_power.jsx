import { useBackend } from '../../backend';
import { PowerMonitor } from '../../PowerMonitor';

export const pda_power = (props) => {
  const { act, data } = useBackend();

  return <PowerMonitorMainContent />;
};
