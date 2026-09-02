import { Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const AtmosAlertConsole = (props) => {
  const { act, data } = useBackend();
  const priorityAlerts = data.priority || [];
  const minorAlerts = data.minor || [];
  const areaModes = data.mode || {};
  return (
    <Window width={350} height={300}>
      <Window.Content scrollable>
        <Section title="Alarms">
          <ul>
            {priorityAlerts.length === 0 && <li className="color-good">No Priority Alerts</li>}
            {priorityAlerts.map((alert) => (
              <li key={alert} className="color-bad">
                {alert}
              </li>
            ))}
            {minorAlerts.length === 0 && <li className="color-good">No Minor Alerts</li>}
            {minorAlerts.map((alert) => (
              <li key={alert} className="color-average">
                {alert}
              </li>
            ))}
            {Object.keys(areaModes).length === 0 && <li className="color-good">All Areas Filtering</li>}
            {Object.entries(areaModes).map(([area, mode]) => (
              <li key={area} className="color-good">
                {area} mode is {mode}
              </li>
            ))}
          </ul>
        </Section>
      </Window.Content>
    </Window>
  );
};
