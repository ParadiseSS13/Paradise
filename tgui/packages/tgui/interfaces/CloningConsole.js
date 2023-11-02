import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Box,
  Tabs,
  Flex,
  Collapsible,
  Icon,
} from '../components';
import { Window } from '../layouts';

const brokenFlag = 1 << 0;
const internalBleedingFlag = 1 << 5;
const burnWoundFlag = 1 << 7;

export const CloningConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { tab, hasScanner, podAmount } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Cloning Console">
          <LabeledList>
            <LabeledList.Item label="Connected scanner">
              {hasScanner ? 'Online' : 'Missing'}
            </LabeledList.Item>
            <LabeledList.Item label="Connected pods">
              {podAmount}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Tabs>
          <Tabs.Tab
            selected={tab === 1}
            icon="home"
            onClick={() => act('menu', { tab: 1 })}
          >
            Main Menu
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 2}
            icon="user"
            onClick={() => act('menu', { tab: 2 })}
          >
            Damage Configuration
          </Tabs.Tab>
        </Tabs>
        <Section>
          <CloningConsoleBody />
        </Section>
      </Window.Content>
    </Window>
  );
};

const CloningConsoleBody = (props, context) => {
  const { data } = useBackend(context);
  const { tab } = data;
  let body;
  if (tab === 1) {
    body = <CloningConsoleMain />;
  } else if (tab === 2) {
    body = <CloningConsoleDamage />;
  }
  return body;
};

const CloningConsoleMain = (props, context) => {
  const { act, data } = useBackend(context);
  const { pods, selectedPodUID } = data;
  return (
    <Box>
      {!pods && <Box color="average">Notice: No pods connected.</Box>}
      {!!pods &&
        pods.map((pod, i) => (
          <Section key={pod} layer={2} title={'Pod ' + (i + 1)}>
            <Flex textAlign="center">
              <Flex.Item basis="96px" shrink={0}>
                <img
                  src={'pod_' + (pod['cloning'] ? 'cloning' : 'idle') + '.gif'}
                  style={{
                    width: '100%',
                    '-ms-interpolation-mode': 'nearest-neighbor',
                  }}
                />
                <Button
                  selected={selectedPodUID === pod['uid']}
                  onClick={() => act('select_pod', { uid: pod['uid'] })}
                >
                  Select
                </Button>
              </Flex.Item>
              <Flex.Item>
                <LabeledList>
                  <LabeledList.Item label="Progress">
                    {!pod['currently_cloning'] && (
                      <Box color="average">Pod is inactive.</Box>
                    )}
                    {!!pod['currently_cloning'] && (
                      <ProgressBar
                        value={pod['clone_progress']}
                        maxValue={100}
                        color="good"
                      />
                    )}
                  </LabeledList.Item>
                  <LabeledList.Divider />
                  <LabeledList.Item label="Biomass">
                    <ProgressBar
                      value={pod['biomass']}
                      ranges={{
                        good: [
                          (2 * pod['biomass_storage_capacity']) / 3,
                          pod['biomass_storage_capacity'],
                        ],
                        average: [
                          pod['biomass_storage_capacity'] / 3,
                          (2 * pod['biomass_storage_capacity']) / 3,
                        ],
                        bad: [0, pod['biomass_storage_capacity'] / 3], // This is just thirds again
                      }}
                      minValue={0}
                      maxValue={pod['biomass_storage_capacity']}
                    >
                      {pod['biomass']}/
                      {pod['biomass_storage_capacity'] +
                        ' (' +
                        (100 * pod['biomass']) /
                          pod['biomass_storage_capacity'] +
                        '%)'}
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item label="Sanguine Reagent">
                    {pod['sanguine_reagent']}
                  </LabeledList.Item>
                  <LabeledList.Item label="Osseous Reagent">
                    {pod['osseous_reagent']}
                  </LabeledList.Item>
                </LabeledList>
              </Flex.Item>
            </Flex>
          </Section>
        ))}
    </Box>
  );
};

const CloningConsoleDamage = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hasScanned,
    scannerHasPatient,
    scannerFeedback,
    scanSuccessful,
    patientLimbData,
    limbList,
    patientOrganData,
    organList,
  } = data;
  return (
    <Box>
      <Section
        layer={2}
        title="Scanner Info"
        buttons={
          <Button icon="hourglass-half" onClick={() => act('scan')}>
            Scan
          </Button>
        }
      >
        {!hasScanned && (
          <Box color="average">
            {scannerHasPatient
              ? 'No scan detected for current patient.'
              : 'No patient is in the scanner.'}
          </Box>
        )}
        {!!hasScanned && (
          <Box color={scannerFeedback['color']}>{scannerFeedback['text']}</Box>
        )}
      </Section>
      <Section layer={2} title="Damages Breakdown">
        <Box>{/* Mass-selection buttons for fixing and stuff TBD later*/}</Box>
        <Box>
          {(!scanSuccessful || !hasScanned) && (
            <Box color="average">No valid scan detected.</Box>
          )}
          {!!scanSuccessful && !!hasScanned && (
            <Box>
              <LimbsMenu />
              <OrgansMenu />
            </Box>
          )}
        </Box>
      </Section>
    </Box>
  );
};

const LimbsMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { patientLimbData, limbList } = data;
  return (
    <Collapsible title="Limbs">
      {limbList.map((limb, i) => (
        <Box key={limb}>
          <Flex align="baseline">
            <Flex.Item color="label" width="15%" height="20px">
              {patientLimbData[limb][4]}:{' '}
            </Flex.Item>
            <Flex.Item grow={1} />
            {patientLimbData[limb][3] === 0 && (
              <Flex.Item width="60%">
                <ProgressBar
                  value={patientLimbData[limb][0] + patientLimbData[limb][1]}
                  maxValue={patientLimbData[limb][5]}
                  ranges={{
                    good: [0, patientLimbData[limb][5] / 3],
                    average: [
                      patientLimbData[limb][5] / 3,
                      (2 * patientLimbData[limb][5]) / 3,
                    ],
                    bad: [
                      (2 * patientLimbData[limb][5]) / 3,
                      patientLimbData[limb][5],
                    ],
                  }}
                >
                  {'Current Damage: '}
                  <Icon name="bone" />
                  {' ' + patientLimbData[limb][0] + ' / '}
                  <Icon name="fire" />
                  {' ' + patientLimbData[limb][1]}
                </ProgressBar>
              </Flex.Item>
            )}
            {!(patientLimbData[limb][3] === 0) && (
              <Flex.Item width="60%">
                <ProgressBar color="bad" value={0}>
                  The patient&apos;s {patientLimbData[limb][4]} is missing!
                </ProgressBar>
              </Flex.Item>
            )}
          </Flex>
          <Flex>
            <Flex.Item>
              <Button.Checkbox
                disabled={
                  !(patientLimbData[limb][0] || patientLimbData[limb][1])
                }
                checked={1}
              >
                Repair Damages
              </Button.Checkbox>
              <Button.Checkbox
                disabled={!(patientLimbData[limb][2] & brokenFlag)}
                checked={1}
              >
                Mend Bone
              </Button.Checkbox>
              <Button.Checkbox
                disabled={!(patientLimbData[limb][2] & internalBleedingFlag)}
                checked={1}
              >
                Mend IB
              </Button.Checkbox>
              <Button.Checkbox
                disabled={!(patientLimbData[limb][2] & burnWoundFlag)}
                checked={1}
              >
                Mend Critical Burn
              </Button.Checkbox>
            </Flex.Item>
          </Flex>
        </Box>
      ))}
    </Collapsible>
  );
};

const OrgansMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { patientOrganData, organList } = data;
  return (
    <Collapsible title="Organs">
      {organList.map((organ, i) => (
        <Box key={organ}>
          <Flex align="baseline">
            <Flex.Item color="label" width="20%" height="20px">
              {patientOrganData[organ][3]}:{' '}
            </Flex.Item>
            <Flex.Item>
              {!!patientOrganData[organ][2] && (
                <Button.Checkbox checked={1}>Replace Organ</Button.Checkbox>
              )}
              {!patientOrganData[organ][2] && (
                <Box>
                  <Button.Checkbox
                    disabled={!patientOrganData[organ][0]}
                    checked={1}
                  >
                    Repair Damages
                  </Button.Checkbox>
                  <Button.Checkbox checked={1}>Replace Organ</Button.Checkbox>
                </Box>
              )}
            </Flex.Item>
            <Flex.Item grow={1} />
            <Flex.Item width="35%">
              {!!patientOrganData[organ][2] && (
                <ProgressBar color="bad" value={0}>
                  The patient&apos;s {patientOrganData[organ][3]} is missing!
                </ProgressBar>
              )}
              {!patientOrganData[organ][2] && (
                <ProgressBar
                  value={patientOrganData[organ][0]}
                  maxValue={patientOrganData[organ][4]}
                  ranges={{
                    good: [0, patientOrganData[organ][4] / 3],
                    average: [
                      patientOrganData[organ][4] / 3,
                      (2 * patientOrganData[organ][4]) / 3,
                    ],
                    bad: [
                      (2 * patientOrganData[organ][4]) / 3,
                      patientOrganData[organ][4],
                    ],
                  }}
                >
                  {'Current Damage: ' + patientOrganData[organ][0]}
                </ProgressBar>
              )}
            </Flex.Item>
          </Flex>
        </Box>
      ))}
    </Collapsible>
  );
};
