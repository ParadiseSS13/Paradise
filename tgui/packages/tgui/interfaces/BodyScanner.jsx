import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const stats = [
  ['good', 'Alive'],
  ['average', 'Critical'],
  ['bad', 'DEAD'],
];

const abnormalities = [
  ['hasVirus', 'bad', 'Viral pathogen detected in blood stream.'],
  ['blind', 'average', 'Cataracts detected.'],
  ['colourblind', 'average', 'Photoreceptor abnormalities detected.'],
  ['nearsighted', 'average', 'Retinal misalignment detected.'],
  ['paraplegic', 'bad', 'Lumbar nerves damaged.'],
];

const damages = [
  ['Respiratory', 'oxyLoss'],
  ['Brain', 'brainLoss'],
  ['Toxin', 'toxLoss'],
  ['Radiation', 'radLoss'],
  ['Brute', 'bruteLoss'],
  ['Cellular', 'cloneLoss'],
  ['Burn', 'fireLoss'],
  ['Inebriation', 'drunkenness'],
];

const damageRange = {
  average: [0.25, 0.5],
  bad: [0.5, Infinity],
};

const mapTwoByTwo = (a, c) => {
  let result = [];
  for (let i = 0; i < a.length; i += 2) {
    result.push(c(a[i], a[i + 1], i));
  }
  return result;
};

const reduceOrganStatus = (A) => {
  return A.length > 0
    ? A.filter((s) => !!s).reduce(
        (a, s) => (
          <>
            {a}
            <Box key={s}>{s}</Box>
          </>
        ),
        null
      )
    : null;
};

const germStatus = (i) => {
  if (i > 100) {
    if (i < 300) {
      return 'mild infection';
    }
    if (i < 400) {
      return 'mild infection+';
    }
    if (i < 500) {
      return 'mild infection++';
    }
    if (i < 700) {
      return 'acute infection';
    }
    if (i < 800) {
      return 'acute infection+';
    }
    if (i < 900) {
      return 'acute infection++';
    }
    if (i >= 900) {
      return 'septic';
    }
  }

  return '';
};

export const BodyScanner = (props) => {
  const { data } = useBackend();
  const { occupied, occupant = {} } = data;
  const body = occupied ? <BodyScannerMain occupant={occupant} /> : <BodyScannerEmpty />;
  return (
    <Window width={700} height={600} title="Body Scanner">
      <Window.Content scrollable>{body}</Window.Content>
    </Window>
  );
};

const BodyScannerMain = (props) => {
  const { occupant } = props;
  return (
    <Box>
      <BodyScannerMainOccupant occupant={occupant} />
      <BodyScannerMainAbnormalities occupant={occupant} />
      <BodyScannerMainDamage occupant={occupant} />
      <BodyScannerMainOrgansExternal organs={occupant.extOrgan} />
      <BodyScannerMainOrgansInternal organs={occupant.intOrgan} />
    </Box>
  );
};

const BodyScannerMainOccupant = (props) => {
  const { act, data } = useBackend();
  const { occupant } = data;
  return (
    <Section
      title="Occupant"
      buttons={
        <>
          <Button icon="print" onClick={() => act('print_p')}>
            Print Report
          </Button>
          <Button icon="user-slash" onClick={() => act('ejectify')}>
            Eject
          </Button>
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Name">{occupant.name}</LabeledList.Item>
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
        <LabeledList.Item label="Status" color={stats[occupant.stat][0]}>
          {stats[occupant.stat][1]}
        </LabeledList.Item>
        <LabeledList.Item label="Temperature">
          <AnimatedNumber value={Math.round(occupant.bodyTempC)} />
          &deg;C,&nbsp;
          <AnimatedNumber value={Math.round(occupant.bodyTempF)} />
          &deg;F
        </LabeledList.Item>
        <LabeledList.Item label="Implants">
          {occupant.implant_len ? (
            <Box>{occupant.implant.map((im) => im.name).join(', ')}</Box>
          ) : (
            <Box color="label">None</Box>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const BodyScannerMainAbnormalities = (props) => {
  const { occupant } = props;
  if (
    !(
      occupant.hasBorer ||
      occupant.blind ||
      occupant.colourblind ||
      occupant.nearsighted ||
      occupant.hasVirus ||
      occupant.paraplegic
    )
  ) {
    return (
      <Section title="Abnormalities">
        <Box color="label">No abnormalities found.</Box>
      </Section>
    );
  }

  return (
    <Section title="Abnormalities">
      {abnormalities.map((a, i) => {
        if (occupant[a[0]]) {
          return (
            <Box key={a[2]} color={a[1]} bold={a[1] === 'bad'}>
              {a[2]}
            </Box>
          );
        }
      })}
    </Section>
  );
};

const BodyScannerMainDamage = (props) => {
  const { occupant } = props;
  return (
    <Section title="Damage">
      <Table>
        {mapTwoByTwo(damages, (d1, d2, i) => (
          <>
            <Table.Row color="label">
              <Table.Cell>{d1[0]}:</Table.Cell>
              <Table.Cell>{!!d2 && d2[0] + ':'}</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <BodyScannerMainDamageBar value={occupant[d1[1]]} marginBottom={i < damages.length - 2} />
              </Table.Cell>
              <Table.Cell>{!!d2 && <BodyScannerMainDamageBar value={occupant[d2[1]]} />}</Table.Cell>
            </Table.Row>
          </>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerMainDamageBar = (props) => {
  return (
    <ProgressBar
      min="0"
      max="100"
      value={props.value / 100}
      mt="0.5rem"
      mb={!!props.marginBottom && '0.5rem'}
      ranges={damageRange}
    >
      {Math.round(props.value)}
    </ProgressBar>
  );
};

const BodyScannerMainOrgansExternal = (props) => {
  if (props.organs.length === 0) {
    return (
      <Section title="External Organs">
        <Box color="label">N/A</Box>
      </Section>
    );
  }

  return (
    <Section title="External Organs">
      <Table>
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell textAlign="center">Damage</Table.Cell>
          <Table.Cell textAlign="right">Injuries</Table.Cell>
        </Table.Row>
        {props.organs.map((o, i) => (
          <Table.Row key={i}>
            <Table.Cell
              color={
                (!!o.status.dead && 'bad') ||
                ((!!o.internalBleeding ||
                  !!o.burnWound ||
                  !!o.lungRuptured ||
                  !!o.status.broken ||
                  !!o.open ||
                  o.germ_level > 100) &&
                  'average') ||
                (!!o.status.robotic && 'label')
              }
              width="33%"
            >
              {capitalize(o.name)}
            </Table.Cell>
            <Table.Cell textAlign="center">
              <ProgressBar
                m={-0.5}
                min="0"
                max={o.maxHealth}
                mt={i > 0 && '0.5rem'}
                value={o.totalLoss / o.maxHealth}
                ranges={damageRange}
              >
                <Stack>
                  <Tooltip content="Total damage">
                    <Stack.Item>
                      <Icon name="heartbeat" mr={0.5} />
                      {Math.round(o.totalLoss)}
                    </Stack.Item>
                  </Tooltip>
                  {!!o.bruteLoss && (
                    <Tooltip content="Brute damage">
                      <Stack.Item grow>
                        <Icon name="bone" mr={0.5} />
                        {Math.round(o.bruteLoss)}
                      </Stack.Item>
                    </Tooltip>
                  )}
                  {!!o.fireLoss && (
                    <Tooltip content="Burn damage">
                      <Stack.Item>
                        <Icon name="fire" mr={0.5} />
                        {Math.round(o.fireLoss)}
                      </Stack.Item>
                    </Tooltip>
                  )}
                </Stack>
              </ProgressBar>
            </Table.Cell>
            <Table.Cell textAlign="right" verticalAlign="top" width="33%" pt={i > 0 && 'calc(0.5rem + 2px)'}>
              <Box color="average" inline>
                {reduceOrganStatus([
                  !!o.internalBleeding && 'Internal bleeding',
                  !!o.burnWound && 'Critical tissue burns',
                  !!o.lungRuptured && 'Ruptured lung',
                  !!o.status.broken && o.status.broken,
                  germStatus(o.germ_level),
                  !!o.open && 'Open incision',
                ])}
              </Box>
              <Box inline>
                {reduceOrganStatus([
                  !!o.status.splinted && <Box color="good">Splinted</Box>,
                  !!o.status.robotic && <Box color="label">Robotic</Box>,
                  !!o.status.dead && (
                    <Box color="bad" bold>
                      DEAD
                    </Box>
                  ),
                ])}
                {reduceOrganStatus(o.shrapnel.map((s) => (s.known ? s.name : 'Unknown object')))}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerMainOrgansInternal = (props) => {
  if (props.organs.length === 0) {
    return (
      <Section title="Internal Organs">
        <Box color="label">N/A</Box>
      </Section>
    );
  }

  return (
    <Section title="Internal Organs">
      <Table>
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell textAlign="center">Damage</Table.Cell>
          <Table.Cell textAlign="right">Injuries</Table.Cell>
        </Table.Row>
        {props.organs.map((o, i) => (
          <Table.Row key={i}>
            <Table.Cell
              color={(!!o.dead && 'bad') || (o.germ_level > 100 && 'average') || (o.robotic > 0 && 'label')}
              width="33%"
            >
              {capitalize(o.name)}
            </Table.Cell>
            <Table.Cell textAlign="center">
              <ProgressBar
                min="0"
                max={o.maxHealth}
                value={o.damage / o.maxHealth}
                mt={i > 0 && '0.5rem'}
                ranges={damageRange}
              >
                {Math.round(o.damage)}
              </ProgressBar>
            </Table.Cell>
            <Table.Cell textAlign="right" verticalAlign="top" width="33%" pt={i > 0 && 'calc(0.5rem + 2px)'}>
              <Box color="average" inline>
                {reduceOrganStatus([germStatus(o.germ_level)])}
              </Box>
              <Box inline>
                {reduceOrganStatus([
                  o.robotic === 1 && <Box color="label">Robotic</Box>,
                  o.robotic === 2 && <Box color="label">Assisted</Box>,
                  !!o.dead && (
                    <Box color="bad" bold>
                      DEAD
                    </Box>
                  ),
                ])}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerEmpty = () => {
  return (
    <Section fill>
      <Stack fill textAlign="center">
        <Stack.Item grow align="center" color="label">
          <Icon name="user-slash" mb="0.5rem" size="5" />
          <br />
          No occupant detected.
        </Stack.Item>
      </Stack>
    </Section>
  );
};
