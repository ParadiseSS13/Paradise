import { round } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Box, Button, Flex, Icon, LabeledList, ProgressBar, Section } from "../components";
import { Window } from "../layouts";

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

export const Sleeper = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hasOccupant,
  } = data;
  const body = hasOccupant ? <SleeperMain /> : <SleeperEmpty />;
  return (
    <Window resizable>
      <Window.Content className="Layout__content--flexColumn">
        {body}
      </Window.Content>
    </Window>
  );
};

const SleeperMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    occupant,
  } = data;
  return (
    <Fragment>
      <SleeperOccupant />
      <SleeperDamage />
      <SleeperChemicals />
      <SleeperDialysis />
    </Fragment>
  );
};

const SleeperOccupant = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    occupant,
    auto_eject_dead,
  } = data;
  return (
    <Section
      title="Occupant"
      buttons={(
        <Fragment>
          <Box color="label" display="inline">
            Auto-eject if dead:&nbsp;
          </Box>
          <Button
            icon={auto_eject_dead ? "toggle-on" : "toggle-off"}
            selected={auto_eject_dead}
            content={auto_eject_dead ? 'On' : 'Off'}
            onClick={() =>
              act('auto_eject_dead_' + (auto_eject_dead ? 'off' : 'on'))}
          />
          <Button
            icon="user-slash"
            content="Eject"
            onClick={() => act('ejectify')}
          />
        </Fragment>
      )}>
      <LabeledList>
        <LabeledList.Item label="Name">
          {occupant.name}
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
            }}>
            {round(occupant.health, 0)}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Status" color={stats[occupant.stat][0]}>
          {stats[occupant.stat][1]}
        </LabeledList.Item>
        <LabeledList.Item label="Temperature">
          <ProgressBar
            min="0"
            max={occupant.maxTemp}
            value={occupant.bodyTemperature / occupant.maxTemp}
            color={tempColors[occupant.temperatureSuitability + 3]}>
            {round(occupant.btCelsius, 0)}&deg;C,
            {round(occupant.btFaren, 0)}&deg;F
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
            <LabeledList.Item label="Pulse" verticalAlign="middle">
              {occupant.pulse} BPM
            </LabeledList.Item>
          </Fragment>
        )}
      </LabeledList>
    </Section>
  );
};

const SleeperDamage = (props, context) => {
  const { data } = useBackend(context);
  const {
    occupant,
  } = data;
  return (
    <Section
      title="Occupant Damage">
      <LabeledList>
        {damages.map((d, i) => (
          <LabeledList.Item key={i} label={d[0]}>
            <ProgressBar
              key={i}
              min="0"
              max="100"
              value={occupant[d[1]] / 100}
              ranges={damageRange}>
              {round(occupant[d[1]], 0)}
            </ProgressBar>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const SleeperDialysis = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    isBeakerLoaded,
    beakerMaxSpace,
    beakerFreeSpace,
    dialysis,
  } = data;
  const canDialysis = dialysis && beakerFreeSpace > 0;
  return (
    <Section
      title="Dialysis"
      buttons={
        <Fragment>
          <Button
            disabled={!isBeakerLoaded || beakerFreeSpace <= 0}
            selected={canDialysis}
            icon={canDialysis ? "toggle-on" : "toggle-off"}
            content={canDialysis ? "Active" : "Inactive"}
            onClick={() => act('togglefilter')}
          />
          <Button
            disabled={!isBeakerLoaded}
            icon="eject"
            content="Eject"
            onClick={() => act('removebeaker')}
          />
        </Fragment>
      }>
      {isBeakerLoaded ? (
        <LabeledList>
          <LabeledList.Item label="Remaining Space">
            <ProgressBar
              min="0"
              max={beakerMaxSpace}
              value={beakerFreeSpace / beakerMaxSpace}
              ranges={{
                good: [0.5, Infinity],
                average: [0.25, 0.5],
                bad: [-Infinity, 0.25],
              }}>
              {beakerFreeSpace}u
            </ProgressBar>
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Box color="label">
          No beaker loaded.
        </Box>
      )}
    </Section>
  );
};

const SleeperChemicals = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    occupant,
    chemicals,
    maxchem,
    amounts,
  } = data;
  return (
    <Section title="Occupant Chemicals" flexGrow="1">
      {chemicals.map((chem, i) => {
        let barColor = '';
        let odWarning;
        if (chem.overdosing) {
          barColor = 'bad';
          odWarning = (
            <Box color="bad">
              <Icon name="exclamation-circle" />&nbsp;
              Overdosing!
            </Box>
          );
        } else if (chem.od_warning) {
          barColor = 'average';
          odWarning = (
            <Box color="average">
              <Icon name="exclamation-triangle" />&nbsp;
              Close to overdosing
            </Box>
          );
        }
        return (
          <Box key={i} backgroundColor="rgba(0, 0, 0, 0.33)" mb="0.5rem">
            <Section
              title={chem.title}
              level="3"
              mx="0"
              lineHeight="18px"
              buttons={odWarning}>
              <Flex align="flex-start">
                <ProgressBar
                  min="0"
                  max={maxchem}
                  value={chem.occ_amount / maxchem}
                  color={barColor}
                  title="Amount of chemicals currently inside the occupant / Total amount injectable by this machine"
                  mr="0.5rem">
                  {chem.pretty_amount}/{maxchem}u
                </ProgressBar>
                {amounts.map((a, i) => (
                  <Button
                    key={i}
                    disabled={!chem.injectable
                      || ((chem.occ_amount + a) > maxchem)
                      || occupant.stat === 2}
                    icon="syringe"
                    content={"Inject "+a+"u"}
                    title={"Inject "+a+"u of "+chem.title + " into the occupant"}
                    mb="0"
                    height="19px"
                    onClick={() => act('chemical', {
                      chemid: chem.id,
                      amount: a,
                    })}
                  />
                ))}
              </Flex>
            </Section>
          </Box>
        );
      })}
    </Section>
  );
};

const SleeperEmpty = (props, context) => {
  return (
    <Section textAlign="center" flexGrow="1">
      <Flex height="100%">
        <Flex.Item grow="1" align="center" color="label">
          <Icon
            name="user-slash"
            mb="0.5rem"
            size="5"
          /><br />
          No occupant detected.
        </Flex.Item>
      </Flex>
    </Section>
  );
};
