import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const AtmosAlertConsole = (props, context) => {
  const { act, data } = useBackend(context);
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
            {Object.keys(areaModes).map((label) => (
              <li key={alert} className="color-good">
                {label} mode is {areaModes[label]}
              </li>
            ))}
          </ul>
        </Section>
      </Window.Content>
    </Window>
  );
};
