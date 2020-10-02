import { round } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Box, Button, Flex, Icon, Modal, LabeledList, ProgressBar, Section, NoticeBox } from "../components";
import { Window } from "../layouts";
import { toTitleCase, decodeHtmlEntities } from 'common/string';

export const MechaControlConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beacons,
    stored_data,
  } = data;

  if (stored_data.length) {
    return (
      <Window resizable>
        <Window.Content scrollable>
          <Section title="Log" buttons={
            <Button icon="window-close"
              onClick={() => act("clear_log")} />
          }>
            {stored_data.map(data => (
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
    <Window resizable>
      <Window.Content scrollable>
        {beacons.length && beacons.map(beacon => (
          <Section key={beacon.name} title={beacon.name} buttons={
            <Fragment>
              <Button
                icon="comment"
                onClick={() => act("send_message", { mt: beacon.uid })}>
                Message
              </Button>
              <Button
                icon="eye"
                onClick={() => act("get_log", { mt: beacon.uid })}>
                View Log
              </Button>
              <Button.Confirm
                color="red"
                content="EMP"
                icon="bomb"
                onClick={() => act("shock", { mt: beacon.uid })} />
            </Fragment>
          }>
            <LabeledList>
              <LabeledList.Item label="Health">
                <ProgressBar
                  ranges={{
                    good: [beacon.maxHealth * 0.75, Infinity],
                    average: [beacon.maxHealth * 0.5, beacon.maxHealth * 0.75],
                    bad: [-Infinity, beacon.maxHealth * 0.5],
                  }}
                  value={beacon.health}
                  maxValue={beacon.maxHealth} />
              </LabeledList.Item>
              <LabeledList.Item label="Cell Charge">
                {beacon.cell && (
                  <ProgressBar
                    ranges={{
                      good: [beacon.cellMaxCharge * 0.75, Infinity],
                      average: [beacon.cellMaxCharge * 0.5,
                        beacon.cellMaxCharge * 0.75],
                      bad: [-Infinity, beacon.cellMaxCharge * 0.5],
                    }}
                    value={beacon.cellCharge}
                    maxValue={beacon.cellMaxCharge} />
                ) || <NoticeBox>No Cell Installed</NoticeBox>}
              </LabeledList.Item>
              <LabeledList.Item label="Air Tank">
                {beacon.airtank}kPa
              </LabeledList.Item>
              <LabeledList.Item label="Pilot">
                {beacon.pilot || "Unoccupied"}
              </LabeledList.Item>
              <LabeledList.Item label="Location">
                {toTitleCase(beacon.location) || "Unknown"}
              </LabeledList.Item>
              <LabeledList.Item label="Active Equipment">
                {beacon.active || "None"}
              </LabeledList.Item>
              {beacon.cargoMax && (
                <LabeledList.Item label="Cargo Space">
                  <ProgressBar
                    ranges={{
                      bad: [beacon.cargoMax * 0.75, Infinity],
                      average: [beacon.cargoMax * 0.5, beacon.cargoMax * 0.75],
                      good: [-Infinity, beacon.cargoMax * 0.5],
                    }}
                    value={beacon.cargoUsed}
                    maxValue={beacon.cargoMax} />
                </LabeledList.Item>
              ) || null}
            </LabeledList>
          </Section>
        )) || (
          <NoticeBox>No mecha beacons found.</NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};
