import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const AtmosAlertConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const priorityAlerts = data.priority || [];
  const minorAlerts = data.minor || [];
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
          </ul>
        </Section>
      </Window.Content>
    </Window>
  );
};
