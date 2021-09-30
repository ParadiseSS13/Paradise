import { useBackend } from "../../backend";
import { PowerMonitorMainContent } from '../PowerMonitor';

export const pda_power = (props, context) => {
  const { act, data } = useBackend(context);

  return <PowerMonitorMainContent />;
};
