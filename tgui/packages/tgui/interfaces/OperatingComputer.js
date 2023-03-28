import { round } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Window } from "../layouts";
import { Box, Button, Flex, Icon, Knob, LabeledList, Section, Tabs, ProgressBar } from "../components";

const stats = [
  ['good', 'Conscious'],
  ['average', 'Unconscious'],
  ['bad', 'DEAD'],
];

const damages = [
  ['Resp.', 'oxyLoss'],
  ['Toxin', 'toxLoss'],
  ['Brute', 'bruteLoss'],
  ['Burn', 'fireLoss'],
];

const damageRange = {
  average: [0.25, 0.5],
  bad: [0.5, Infinity],
};

const tempColors = [
  'bad',
  'average',
  'average',
  'good',
  'average',
  'average',
  'bad',
];

export const OperatingComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hasOccupant,
    choice,
  } = data;
  let body;
  if (!choice) {
    body = hasOccupant
      ? <OperatingComputerPatient />
      : <OperatingComputerUnoccupied />;
  } else {
    body = <OperatingComputerOptions />;
  }
  return (
    <Window resizable>
      <Window.Content className="Layout__content--flexColumn">
        <Tabs>
          <Tabs.Tab
            selected={!choice}
            icon="user"
            onClick={() => act('choiceOff')}>
            Patient
          </Tabs.Tab>
          <Tabs.Tab
            selected={!!choice}
            icon="cog"
            onClick={() => act('choiceOn')}>
            Options
          </Tabs.Tab>
        </Tabs>
        <Section flexGrow="1">
          {body}
        </Section>
      </Window.Content>
    </Window>
  );
};

const OperatingComputerPatient = (props, context) => {
  const { data } = useBackend(context);
  const {
    occupant,
  } = data;
  return (
    <Fragment>
      <Section title="Patient" level="2">
        <LabeledList>
          <LabeledList.Item label="Name">
            {occupant.name}
          </LabeledList.Item>
          <LabeledList.Item label="Status" color={stats[occupant.stat][0]}>
            {stats[occupant.stat][1]}
          </LabeledList.Item>
          <LabeledList.Item label="Health">
            <ProgressBar
              min="0"
              max={occupant.maxHealth}
              value={occupant.health / occupant.maxHealth}
              ranges={{
                good: [0.5, Infinity],
                average: [0, 0.5],
                bad: [-Infinity, 0],
              }}
            />
          </LabeledList.Item>
          {damages.map((d, i) => (
            <LabeledList.Item key={i} label={d[0] + " Damage"}>
              <ProgressBar
                key={i}
                min="0"
                max="100"
                value={occupant[d[1]] / 100}
                ranges={damageRange}>
                {round(occupant[d[1]])}
              </ProgressBar>
            </LabeledList.Item>
          ))}
          <LabeledList.Item label="Temperature">
            <ProgressBar
              min="0"
              max={occupant.maxTemp}
              value={occupant.bodyTemperature / occupant.maxTemp}
              color={tempColors[occupant.temperatureSuitability + 3]}>
              {round(occupant.btCelsius)}&deg;C, {round(occupant.btFaren)}&deg;F
            </ProgressBar>
          </LabeledList.Item>
          {!!occupant.hasBlood && (
            <Fragment>
              <LabeledList.Item label="Blood Level">
                <ProgressBar
                  min="0"
                  max={occupant.bloodMax}
                  value={occupant.bloodLevel / occupant.bloodMax}
                  ranges={{
                    bad: [-Infinity, 0.6],
                    average: [0.6, 0.9],
                    good: [0.6, Infinity],
                  }}>
                  {occupant.bloodPercent}%, {occupant.bloodLevel}cl
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Pulse">
                {occupant.pulse} BPM
              </LabeledList.Item>
            </Fragment>
          )}
        </LabeledList>
      </Section>
      <Section title="Current Procedures" level="2">
        {occupant.inSurgery ? (
          occupant.surgeries.map(({ bodypartName, surgeryName, stepName }) => (
            <Section title={bodypartName} level="4" key={bodypartName}>
              <LabeledList>
                <LabeledList.Item label="Procedure">
                  {surgeryName}
                </LabeledList.Item>
                <LabeledList.Item label="Next Step">
                  {stepName}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ))
        ) : (
          <Box color="label">
            No procedures ongoing.
          </Box>
        )}
      </Section>
    </Fragment>
  );
};

const OperatingComputerUnoccupied = () => {
  return (
    <Flex textAlign="center" height="100%">
      <Flex.Item grow="1" align="center" color="label">
        <Icon
          name="user-slash"
          mb="0.5rem"
          size="5"
        /><br />
        No patient detected.
      </Flex.Item>
    </Flex>
  );
};

const OperatingComputerOptions = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    verbose,
    health,
    healthAlarm,
    oxy,
    oxyAlarm,
    crit,
  } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="Loudspeaker">
        <Button
          selected={verbose}
          icon={verbose ? "toggle-on" : "toggle-off"}
          content={verbose ? "On" : "Off"}
          onClick={() => act(verbose ? 'verboseOff' : 'verboseOn')}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Health Announcer">
        <Button
          selected={health}
          icon={health ? "toggle-on" : "toggle-off"}
          content={health ? "On" : "Off"}
          onClick={() => act(health ? 'healthOff' : 'healthOn')}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Health Announcer Threshold">
        <Knob
          bipolar
          minValue="-100"
          maxValue="100"
          value={healthAlarm}
          stepPixelSize="5"
          ml="0"
          onChange={(e, val) => act('health_adj', {
            new: val,
          })}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Oxygen Alarm">
        <Button
          selected={oxy}
          icon={oxy ? "toggle-on" : "toggle-off"}
          content={oxy ? "On" : "Off"}
          onClick={() => act(oxy ? 'oxyOff' : 'oxyOn')}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Oxygen Alarm Threshold">
        <Knob
          bipolar
          minValue="-100"
          maxValue="100"
          value={oxyAlarm}
          stepPixelSize="5"
          ml="0"
          onChange={(e, val) => act('oxy_adj', {
            new: val,
          })}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Critical Alert">
        <Button
          selected={crit}
          icon={crit ? "toggle-on" : "toggle-off"}
          content={crit ? "On" : "Off"}
          onClick={() => act(crit ? 'critOff' : 'critOn')}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};
