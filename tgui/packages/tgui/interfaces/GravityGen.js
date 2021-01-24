// code\modules\power\gravitygenerator.dm
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const GravityGen = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    charging_state,
    charge_count,
    breaker,
    ext_power,
  } = data;

  let chargeStatus = state => {
    if (state > 0) {
      return (
        <Box inline color="average">
          [ {state === 1 ? "Charging" : "Discharging"} ]
        </Box>
      );
    } else {
      return (
        <Box inline color={ext_power ? 'good' : 'bad'}>
          [ {ext_power ? "Powered" : "Unpowered"} ]
        </Box>
      );
    }
  };

  let radWarning = state => {
    if (state > 0) {
      return (
        <NoticeBox danger p={1.5}>
          <b>WARNING:</b> Radiation Detected!
        </NoticeBox>
      );
    }
  };

  return (
    <Window>
      <Window.Content>
        {radWarning(charging_state)}
        <Section
          title="Generator Status"
          buttons={
            <Button
              icon={breaker ? 'power-off' : 'times'}
              content={breaker ? "Online" : "Offline"}
              color={breaker ? 'green' : 'red'}
              px={1.5}
              onClick={() => act('breaker')} />
          }>
          <LabeledList>
            <LabeledList.Item
              label="Power Status"
              color={ext_power ? 'good' : 'bad'}>
              {chargeStatus(charging_state)}
            </LabeledList.Item>
            <LabeledList.Item label="Gravity Charge">
              <ProgressBar
                value={charge_count / 100}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.5, 0.9],
                  bad: [-Infinity, 0.5],
                }} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
