import { Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const StationAlertConsole = () => {
  return (
    <Window width={325} height={500}>
      <Window.Content scrollable>
        <StationAlertConsoleContent />
      </Window.Content>
    </Window>
  );
};

export const StationAlertConsoleContent = (props) => {
  const { data } = useBackend();
  const categories = data.alarms || [];
  const fire = categories['Fire'] || [];
  const atmos = categories['Atmosphere'] || [];
  const power = categories['Power'] || [];
  return (
    <>
      <Section title="Fire Alarms">
        <ul>
          {fire.length === 0 && <li className="color-good">Systems Nominal</li>}
          {fire.map((alert) => (
            <li key={alert} className="color-average">
              {alert}
            </li>
          ))}
        </ul>
      </Section>
      <Section title="Atmospherics Alarms">
        <ul>
          {atmos.length === 0 && <li className="color-good">Systems Nominal</li>}
          {atmos.map((alert) => (
            <li key={alert} className="color-average">
              {alert}
            </li>
          ))}
        </ul>
      </Section>
      <Section title="Power Alarms">
        <ul>
          {power.length === 0 && <li className="color-good">Systems Nominal</li>}
          {power.map((alert) => (
            <li key={alert} className="color-average">
              {alert}
            </li>
          ))}
        </ul>
      </Section>
    </>
  );
};
