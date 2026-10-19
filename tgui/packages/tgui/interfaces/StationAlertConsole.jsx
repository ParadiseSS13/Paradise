import { useState } from 'react';
import { Box, Button, Icon, Section, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NanoMap } from '../components';
import { Window } from '../layouts';

export const StationAlertConsole = () => {
  const { act, data } = useBackend();
  const [tabIndex, setTabIndex] = useState(0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <StationAlertsDataView />;
      case 1:
        return <StationAlertsMapView />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={800} height={600}>
      <Window.Content scrollable={tabIndex === 0}>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab key="DataView" selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
              <Icon name="table" /> Data View
            </Tabs.Tab>
            <Tabs.Tab key="MapView" selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
              <Icon name="map-marked-alt" /> Map View
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

const StationAlertsDataView = (props) => {
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
            <li key={alert.uid} className="color-average">
              {alert.area}
            </li>
          ))}
        </ul>
      </Section>
      <Section title="Atmospherics Alarms">
        <ul>
          {atmos.length === 0 && <li className="color-good">Systems Nominal</li>}
          {atmos.map((alert) => (
            <li key={alert.uid} className="color-average">
              {alert.area}
            </li>
          ))}
        </ul>
      </Section>
      <Section title="Power Alarms">
        <ul>
          {power.length === 0 && <li className="color-good">Systems Nominal</li>}
          {power.map((alert) => (
            <li key={alert.uid} className="color-average">
              {alert.area}
            </li>
          ))}
        </ul>
      </Section>
    </>
  );
};

const StationAlertsMapView = (props) => {
  const { data } = useBackend();
  const [alarmType, setAlarmType] = useState('Fire');
  const categories = data.alarms || [];
  return (
    <>
      <Box align="right">
        <Box inline mr={2} color="label">
          Show:
        </Box>
        <Button.Checkbox checked={alarmType === 'Fire'} content="Fire" onClick={() => setAlarmType('Fire')} />
        <Button.Checkbox
          checked={alarmType === 'Atmosphere'}
          content="Atmosphere"
          onClick={() => setAlarmType('Atmosphere')}
        />
        <Button.Checkbox checked={alarmType === 'Power'} content="Power" onClick={() => setAlarmType('Power')} />
      </Box>
      <Box height="526px" mb="0.5rem" overflow="hidden">
        <NanoMap>
          {categories[alarmType].map((at) => (
            <NanoMap.MarkerIcon
              key={at.uid}
              x={at.x}
              y={at.y}
              icon={getIcon(alarmType)}
              tooltip={at.area}
              color="red"
            />
          ))}
        </NanoMap>
      </Box>
    </>
  );
};

const getIcon = (alarmType) => {
  switch (alarmType) {
    case 'Fire':
      return 'fa-fire';
    case 'Atmosphere':
      return 'fa-wind';
    case 'Power':
      return 'fa-bolt';
    default:
      return 'fa-question';
  }
};
