import { Box, Button, Icon, Knob, LabeledList, ProgressBar, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

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

const tempColors = ['bad', 'average', 'average', 'good', 'average', 'average', 'bad'];

export const OperatingComputer = (props) => {
  const { act, data } = useBackend();
  const { hasOccupant, choice } = data;
  let body;
  if (!choice) {
    body = hasOccupant ? <OperatingComputerPatient /> : <OperatingComputerUnoccupied />;
  } else {
    body = <OperatingComputerOptions />;
  }
  return (
    <Window width={650} height={455}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab selected={!choice} icon="user" onClick={() => act('choiceOff')}>
                Patient
              </Tabs.Tab>
              <Tabs.Tab selected={!!choice} icon="cog" onClick={() => act('choiceOn')}>
                Options
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              {body}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const OperatingComputerPatient = (props) => {
  const { data } = useBackend();
  const { occupant } = data;
  const { activeSurgeries } = occupant;
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill title="Patient">
          <LabeledList>
            <LabeledList.Item label="Name">{occupant.name}</LabeledList.Item>
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
              <LabeledList.Item key={i} label={d[0] + ' Damage'}>
                <ProgressBar key={i} min="0" max="100" value={occupant[d[1]] / 100} ranges={damageRange}>
                  {Math.round(occupant[d[1]])}
                </ProgressBar>
              </LabeledList.Item>
            ))}
            <LabeledList.Item label="Temperature">
              <ProgressBar
                min="0"
                max={occupant.maxTemp}
                value={occupant.bodyTemperature / occupant.maxTemp}
                color={tempColors[occupant.temperatureSuitability + 3]}
              >
                {Math.round(occupant.btCelsius)}&deg;C, {Math.round(occupant.btFaren)}
                &deg;F
              </ProgressBar>
            </LabeledList.Item>
            {!!occupant.hasBlood && (
              <>
                <LabeledList.Item label="Blood Level">
                  <ProgressBar
                    min="0"
                    max={occupant.bloodMax}
                    value={occupant.bloodLevel / occupant.bloodMax}
                    ranges={{
                      bad: [-Infinity, 0.6],
                      average: [0.6, 0.9],
                      good: [0.6, Infinity],
                    }}
                  >
                    {occupant.bloodPercent}%, {occupant.bloodLevel}cl
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Pulse">{occupant.pulse} BPM</LabeledList.Item>
              </>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Active surgeries" level="2">
          {occupant.inSurgery && !!activeSurgeries ? (
            activeSurgeries.map((s, i) => (
              <Section style={{ textTransform: 'capitalize' }} title={s.name + ' (' + s.location + ')'} key={i}>
                <LabeledList key={i}>
                  <LabeledList.Item key={i} label="Next Step">
                    {s.step}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            ))
          ) : (
            <Box color="label">No procedure ongoing.</Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const OperatingComputerUnoccupied = () => {
  return (
    <Stack fill>
      <Stack.Item grow align="center" textAlign="center" color="label">
        <Icon name="user-slash" mb="0.5rem" size="5" />
        <br />
        No patient detected.
      </Stack.Item>
    </Stack>
  );
};

const OperatingComputerOptions = (props) => {
  const { act, data } = useBackend();
  const { verbose, health, healthAlarm, oxy, oxyAlarm, crit } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="Loudspeaker">
        <Button
          selected={verbose}
          icon={verbose ? 'toggle-on' : 'toggle-off'}
          content={verbose ? 'On' : 'Off'}
          onClick={() => act(verbose ? 'verboseOff' : 'verboseOn')}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Health Announcer">
        <Button
          selected={health}
          icon={health ? 'toggle-on' : 'toggle-off'}
          content={health ? 'On' : 'Off'}
          onClick={() => act(health ? 'healthOff' : 'healthOn')}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Health Announcer Threshold">
        <Knob
          bipolar
          minValue={-100}
          maxValue={100}
          value={healthAlarm}
          stepPixelSize={5}
          ml="0"
          onChange={(e, val) =>
            act('health_adj', {
              new: val,
            })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label="Oxygen Alarm">
        <Button
          selected={oxy}
          icon={oxy ? 'toggle-on' : 'toggle-off'}
          content={oxy ? 'On' : 'Off'}
          onClick={() => act(oxy ? 'oxyOff' : 'oxyOn')}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Oxygen Alarm Threshold">
        <Knob
          bipolar
          minValue={-100}
          maxValue={100}
          value={oxyAlarm}
          stepPixelSize={5}
          ml="0"
          onChange={(e, val) =>
            act('oxy_adj', {
              new: val,
            })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label="Critical Alert">
        <Button
          selected={crit}
          icon={crit ? 'toggle-on' : 'toggle-off'}
          content={crit ? 'On' : 'Off'}
          onClick={() => act(crit ? 'critOff' : 'critOn')}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};
