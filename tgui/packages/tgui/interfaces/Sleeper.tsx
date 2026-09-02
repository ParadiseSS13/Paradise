import { Box, Button, Icon, LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';
import { round } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SleeperData {
  hasOccupant: boolean;
  isBeakerLoaded: boolean;
  beakerMaxSpace: number;
  beakerFreeSpace: number;
  dialysis: boolean;
  auto_eject_dead: boolean;
  maxchem: number;
  amounts: number[];
  occupant: {
    name: string;
    health: number;
    maxHealth: number;
    stat: number;
    bodyTemperature: number;
    maxTemp: number;
    btCelsius: number;
    btFaren: number;
    temperatureSuitability: number;
    hasBlood: boolean;
    bloodMax: number;
    bloodLevel: number;
    bloodPercent: number;
    pulse: number;
    oxyLoss: number;
    toxLoss: number;
    bruteLoss: number;
    fireLoss: number;
  };
  chemicals: {
    id: string;
    title: string;
    occ_amount: number;
    pretty_amount: string;
    overdosing: boolean;
    od_warning: boolean;
    injectable: boolean;
  }[];
}

const stats = [
  ['good', 'Alive'],
  ['average', 'Critical'],
  ['bad', 'DEAD'],
];

const damages = [
  ['Resp.', 'oxyLoss'],
  ['Toxin', 'toxLoss'],
  ['Brute', 'bruteLoss'],
  ['Burn', 'fireLoss'],
];

const damageRange: Record<string, [number, number]> = {
  average: [0.25, 0.5],
  bad: [0.5, Infinity],
};

const tempColors = ['bad', 'average', 'average', 'good', 'average', 'average', 'bad'];

export const Sleeper = (props: {}) => {
  const { act, data } = useBackend<SleeperData>();
  const { hasOccupant } = data;
  const body = hasOccupant ? <SleeperMain /> : <SleeperEmpty />;
  return (
    <Window width={550} height={760}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item grow>{body}</Stack.Item>
          <Stack.Item>
            <SleeperDialysis />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SleeperMain = (props: {}) => {
  return (
    <>
      <SleeperOccupant />
      <SleeperDamage />
      <SleeperChemicals />
    </>
  );
};

const SleeperOccupant = (props: {}) => {
  const { act, data } = useBackend<SleeperData>();
  const { occupant, auto_eject_dead } = data;
  return (
    <Section
      title="Occupant"
      buttons={
        <>
          <Box color="label" inline>
            Auto-eject if dead:&nbsp;
          </Box>
          <Button
            icon={auto_eject_dead ? 'toggle-on' : 'toggle-off'}
            selected={auto_eject_dead}
            content={auto_eject_dead ? 'On' : 'Off'}
            onClick={() => act('auto_eject_dead_' + (auto_eject_dead ? 'off' : 'on'))}
          />
          <Button icon="user-slash" content="Eject" onClick={() => act('ejectify')} />
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Name">{occupant.name}</LabeledList.Item>
        <LabeledList.Item label="Health">
          <ProgressBar
            minValue={0}
            maxValue={occupant.maxHealth}
            value={occupant.health}
            ranges={{
              good: [0.5 * occupant.maxHealth, Infinity],
              average: [0, 0.5 * occupant.maxHealth],
              bad: [-Infinity, 0],
            }}
          >
            {round(occupant.health, 0)}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Status" color={stats[occupant.stat][0]}>
          {stats[occupant.stat][1]}
        </LabeledList.Item>
        <LabeledList.Item label="Temperature">
          <ProgressBar
            minValue={0}
            maxValue={occupant.maxTemp}
            value={occupant.bodyTemperature}
            color={tempColors[occupant.temperatureSuitability + 3]}
          >
            {round(occupant.btCelsius, 0)}°C, {round(occupant.btFaren, 0)}°F
          </ProgressBar>
        </LabeledList.Item>
        {!!occupant.hasBlood && (
          <>
            <LabeledList.Item label="Blood Level">
              <ProgressBar
                minValue={0}
                maxValue={occupant.bloodMax}
                value={occupant.bloodLevel}
                ranges={{
                  bad: [-Infinity, 0.6 * occupant.bloodMax],
                  average: [0.6 * occupant.bloodMax, 0.9 * occupant.bloodMax],
                  good: [0.9 * occupant.bloodMax, Infinity],
                }}
              >
                {occupant.bloodPercent}%, {occupant.bloodLevel}cl
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Pulse" verticalAlign="middle">
              {occupant.pulse} BPM
            </LabeledList.Item>
          </>
        )}
      </LabeledList>
    </Section>
  );
};

const SleeperDamage = (props: {}) => {
  const { data } = useBackend<SleeperData>();
  const { occupant } = data;
  return (
    <Section title="Occupant Damage">
      <LabeledList>
        {damages.map((d, i) => {
          const damage = occupant[d[1] as keyof typeof occupant];
          const value = typeof damage === 'number' ? damage : 0;
          return (
            <LabeledList.Item key={i} label={d[0]}>
              <ProgressBar key={i} minValue={0} maxValue={100} value={value} ranges={damageRange}>
                {round(value, 0)}
              </ProgressBar>
            </LabeledList.Item>
          );
        })}
      </LabeledList>
    </Section>
  );
};

const SleeperDialysis = (props: {}) => {
  const { act, data } = useBackend<SleeperData>();
  const { hasOccupant, isBeakerLoaded, beakerMaxSpace, beakerFreeSpace, dialysis } = data;
  const canDialysis = dialysis && beakerFreeSpace > 0;
  return (
    <Section
      title="Dialysis"
      buttons={
        <>
          <Button
            disabled={!isBeakerLoaded || beakerFreeSpace <= 0 || !hasOccupant}
            selected={canDialysis}
            icon={canDialysis ? 'toggle-on' : 'toggle-off'}
            content={canDialysis ? 'Active' : 'Inactive'}
            onClick={() => act('togglefilter')}
          />
          <Button disabled={!isBeakerLoaded} icon="eject" content="Eject" onClick={() => act('removebeaker')} />
        </>
      }
    >
      {isBeakerLoaded ? (
        <LabeledList>
          <LabeledList.Item label="Remaining Space">
            <ProgressBar
              minValue={0}
              maxValue={beakerMaxSpace}
              value={beakerFreeSpace}
              ranges={{
                good: [0.5 * beakerMaxSpace, Infinity],
                average: [0.25 * beakerMaxSpace, 0.5 * beakerMaxSpace],
                bad: [-Infinity, 0.25 * beakerMaxSpace],
              }}
            >
              {beakerFreeSpace}u
            </ProgressBar>
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Box color="label">No beaker loaded.</Box>
      )}
    </Section>
  );
};

const SleeperChemicals = (props: {}) => {
  const { act, data } = useBackend<SleeperData>();
  const { occupant, chemicals, maxchem, amounts } = data;
  return (
    <Section title="Occupant Chemicals">
      {chemicals.map((chem, i) => {
        let barColor = '';
        let odWarning;
        if (chem.overdosing) {
          barColor = 'bad';
          odWarning = (
            <Box color="bad">
              <Icon name="exclamation-circle" />
              &nbsp; Overdosing!
            </Box>
          );
        } else if (chem.od_warning) {
          barColor = 'average';
          odWarning = (
            <Box color="average">
              <Icon name="exclamation-triangle" />
              &nbsp; Close to overdosing
            </Box>
          );
        }
        return (
          <Box key={i} backgroundColor="rgba(0, 0, 0, 0.33)" mb="0.5rem">
            <Section title={chem.title} buttons={odWarning}>
              <Stack>
                <ProgressBar minValue={0} maxValue={maxchem} value={chem.occ_amount} color={barColor} mr="0.5rem">
                  {chem.pretty_amount}/{maxchem}u
                </ProgressBar>
                {amounts.map((a, j) => (
                  <Button
                    key={j}
                    disabled={!chem.injectable || chem.occ_amount + a > maxchem || occupant.stat === 2}
                    icon="syringe"
                    content={`Inject ${a}u`}
                    mb="0"
                    height="19px"
                    onClick={() =>
                      act('chemical', {
                        chemid: chem.id,
                        amount: a,
                      })
                    }
                  />
                ))}
              </Stack>
            </Section>
          </Box>
        );
      })}
    </Section>
  );
};

const SleeperEmpty = (props: {}) => {
  return (
    <Section fill textAlign="center">
      <Stack fill>
        <Stack.Item grow align="center" color="label">
          <Icon name="user-slash" mb="0.5rem" size={5} />
          <br />
          No occupant detected.
        </Stack.Item>
      </Stack>
    </Section>
  );
};
