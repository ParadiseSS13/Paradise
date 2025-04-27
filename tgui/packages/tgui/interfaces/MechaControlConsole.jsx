import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from 'tgui-core/components';
import { decodeHtmlEntities, toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const MechaControlConsole = (props) => {
  const { act, data } = useBackend();
  const { beacons, stored_data } = data;

  if (stored_data.length) {
    return (
      <Window width={420} height={500}>
        <Window.Content scrollable>
          <Section title="Log" buttons={<Button icon="window-close" onClick={() => act('clear_log')} />}>
            {stored_data.map((data) => (
              <Box key={data.time}>
                <Box color="label">({data.time})</Box>
                <Box>{decodeHtmlEntities(data.message)}</Box>
              </Box>
            ))}
          </Section>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window width={420} height={500}>
      <Window.Content scrollable>
        {(beacons.length &&
          beacons.map((beacon) => (
            <Section
              key={beacon.name}
              title={beacon.name}
              buttons={
                <>
                  <Button icon="comment" onClick={() => act('send_message', { mt: beacon.uid })}>
                    Message
                  </Button>
                  <Button icon="eye" onClick={() => act('get_log', { mt: beacon.uid })}>
                    View Log
                  </Button>
                  <Button.Confirm
                    color="red"
                    content="Sabotage"
                    icon="bomb"
                    onClick={() => act('shock', { mt: beacon.uid })}
                  />
                </>
              }
            >
              <LabeledList>
                <LabeledList.Item label="Health">
                  <ProgressBar
                    ranges={{
                      good: [beacon.maxHealth * 0.75, Infinity],
                      average: [beacon.maxHealth * 0.5, beacon.maxHealth * 0.75],
                      bad: [-Infinity, beacon.maxHealth * 0.5],
                    }}
                    value={beacon.health}
                    maxValue={beacon.maxHealth}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Cell Charge">
                  {(beacon.cell && (
                    <ProgressBar
                      ranges={{
                        good: [beacon.cellMaxCharge * 0.75, Infinity],
                        average: [beacon.cellMaxCharge * 0.5, beacon.cellMaxCharge * 0.75],
                        bad: [-Infinity, beacon.cellMaxCharge * 0.5],
                      }}
                      value={beacon.cellCharge}
                      maxValue={beacon.cellMaxCharge}
                    />
                  )) || <NoticeBox>No Cell Installed</NoticeBox>}
                </LabeledList.Item>
                <LabeledList.Item label="Air Tank">{beacon.airtank}kPa</LabeledList.Item>
                <LabeledList.Item label="Pilot">{beacon.pilot || 'Unoccupied'}</LabeledList.Item>
                <LabeledList.Item label="Location">{toTitleCase(beacon.location) || 'Unknown'}</LabeledList.Item>
                <LabeledList.Item label="Active Equipment">{beacon.active || 'None'}</LabeledList.Item>
                {(beacon.cargoMax && (
                  <LabeledList.Item label="Cargo Space">
                    <ProgressBar
                      ranges={{
                        bad: [beacon.cargoMax * 0.75, Infinity],
                        average: [beacon.cargoMax * 0.5, beacon.cargoMax * 0.75],
                        good: [-Infinity, beacon.cargoMax * 0.5],
                      }}
                      value={beacon.cargoUsed}
                      maxValue={beacon.cargoMax}
                    />
                  </LabeledList.Item>
                )) ||
                  null}
              </LabeledList>
            </Section>
          ))) || <NoticeBox>No mecha beacons found.</NoticeBox>}
      </Window.Content>
    </Window>
  );
};
