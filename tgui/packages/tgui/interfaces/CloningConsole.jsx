import { Box, Button, Collapsible, Icon, LabeledList, ProgressBar, Section, Stack, Tabs } from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

const brokenFlag = 1 << 0;
const internalBleedingFlag = 1 << 5;
const burnWoundFlag = 1 << 7;

export const CloningConsole = (props) => {
  const { act, data } = useBackend();
  const { tab, has_scanner, pod_amount } = data;
  return (
    <Window width={640} height={520}>
      <Window.Content scrollable>
        <Section title="Cloning Console">
          <LabeledList>
            <LabeledList.Item label="Connected scanner">{has_scanner ? 'Online' : 'Missing'}</LabeledList.Item>
            <LabeledList.Item label="Connected pods">{pod_amount}</LabeledList.Item>
          </LabeledList>
        </Section>
        <Tabs>
          <Tabs.Tab selected={tab === 1} icon="home" onClick={() => act('menu', { tab: 1 })}>
            Main Menu
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} icon="user" onClick={() => act('menu', { tab: 2 })}>
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

const CloningConsoleBody = (props) => {
  const { data } = useBackend();
  const { tab } = data;
  let body;
  if (tab === 1) {
    body = <CloningConsoleMain />;
  } else if (tab === 2) {
    body = <CloningConsoleDamage />;
  }
  return body;
};

const CloningConsoleMain = (props) => {
  const { act, data } = useBackend();
  const { pods, pod_amount, selected_pod_UID } = data;
  return (
    <Box>
      {!pod_amount && <Box color="average">Notice: No pods connected.</Box>}
      {!!pod_amount &&
        pods.map((pod, i) => (
          <Section key={pod} layer={2} title={'Pod ' + (i + 1)}>
            <Stack textAlign="center">
              <Stack.Item basis="96px" shrink={0}>
                <img
                  src={resolveAsset('pod_' + (pod['cloning'] ? 'cloning' : 'idle') + '.gif')}
                  style={{
                    width: '100%',
                    imageRendering: 'pixelated',
                  }}
                />
                <Button
                  selected={selected_pod_UID === pod['uid']}
                  onClick={() => act('select_pod', { uid: pod['uid'] })}
                >
                  Select
                </Button>
              </Stack.Item>
              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item label="Progress">
                    {!pod['cloning'] && <Box color="average">Pod is inactive.</Box>}
                    {!!pod['cloning'] && <ProgressBar value={pod['clone_progress']} maxValue={100} color="good" />}
                  </LabeledList.Item>
                  <LabeledList.Divider />
                  <LabeledList.Item label="Biomass">
                    <ProgressBar
                      value={pod['biomass']}
                      ranges={{
                        good: [(2 * pod['biomass_storage_capacity']) / 3, pod['biomass_storage_capacity']],
                        average: [pod['biomass_storage_capacity'] / 3, (2 * pod['biomass_storage_capacity']) / 3],
                        bad: [0, pod['biomass_storage_capacity'] / 3], // This is just thirds again
                      }}
                      minValue={0}
                      maxValue={pod['biomass_storage_capacity']}
                    >
                      {pod['biomass']}/
                      {pod['biomass_storage_capacity'] +
                        ' (' +
                        (100 * pod['biomass']) / pod['biomass_storage_capacity'] +
                        '%)'}
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item label="Sanguine Reagent">{pod['sanguine_reagent']}</LabeledList.Item>
                  <LabeledList.Item label="Osseous Reagent">{pod['osseous_reagent']}</LabeledList.Item>
                </LabeledList>
              </Stack.Item>
            </Stack>
          </Section>
        ))}
    </Box>
  );
};

const CloningConsoleDamage = (props) => {
  const { act, data } = useBackend();
  const {
    selected_pod_data,
    has_scanned,
    scanner_has_patient,
    feedback,
    scan_successful,
    cloning_cost,
    has_scanner,
    currently_scanning,
  } = data;
  return (
    <Box>
      {!has_scanner && <Box color="average">Notice: No scanner connected.</Box>}
      {!!has_scanner && (
        <Box>
          <Section
            layer={2}
            title="Scanner Info"
            buttons={
              <Box>
                <Button
                  icon="hourglass-half"
                  onClick={() => act('scan')}
                  disabled={!scanner_has_patient || currently_scanning}
                >
                  Scan
                </Button>
                <Button icon="eject" onClick={() => act('eject')} disabled={!scanner_has_patient || currently_scanning}>
                  Eject Patient
                </Button>
              </Box>
            }
          >
            {!has_scanned && !currently_scanning && (
              <Box color="average">
                {scanner_has_patient ? 'No scan detected for current patient.' : 'No patient is in the scanner.'}
              </Box>
            )}
            {(!!has_scanned || !!currently_scanning) && <Box color={feedback['color']}>{feedback['text']}</Box>}
          </Section>
          <Section layer={2} title="Damages Breakdown">
            <Box>
              {(!scan_successful || !has_scanned) && <Box color="average">No valid scan detected.</Box>}
              {!!scan_successful && !!has_scanned && (
                <Box>
                  <Stack>
                    <Stack.Item>
                      <Button onClick={() => act('fix_all')}>Repair All Damages</Button>
                      <Button onClick={() => act('fix_none')}>Repair No Damages</Button>
                    </Stack.Item>
                    <Stack.Item grow={1} />
                    <Stack.Item>
                      <Button onClick={() => act('clone')}>Clone</Button>
                    </Stack.Item>
                  </Stack>
                  <Stack height="25px">
                    <Stack.Item width="40%">
                      <ProgressBar
                        value={cloning_cost[0]}
                        maxValue={selected_pod_data['biomass_storage_capacity']}
                        ranges={{
                          bad: [
                            (2 * selected_pod_data['biomass_storage_capacity']) / 3,
                            selected_pod_data['biomass_storage_capacity'],
                          ],
                          average: [
                            selected_pod_data['biomass_storage_capacity'] / 3,
                            (2 * selected_pod_data['biomass_storage_capacity']) / 3,
                          ],
                          good: [0, selected_pod_data['biomass_storage_capacity'] / 3],
                        }}
                        color={cloning_cost[0] > selected_pod_data['biomass'] ? 'bad' : null}
                      >
                        Biomass: {cloning_cost[0]}/{selected_pod_data['biomass']}/
                        {selected_pod_data['biomass_storage_capacity']}
                      </ProgressBar>
                    </Stack.Item>
                    <Stack.Item width="30%">
                      <ProgressBar
                        value={cloning_cost[1]}
                        maxValue={selected_pod_data['max_reagent_capacity']}
                        ranges={{
                          bad: [
                            (2 * selected_pod_data['max_reagent_capacity']) / 3,
                            selected_pod_data['max_reagent_capacity'],
                          ],
                          average: [
                            selected_pod_data['max_reagent_capacity'] / 3,
                            (2 * selected_pod_data['max_reagent_capacity']) / 3,
                          ],
                          good: [0, selected_pod_data['max_reagent_capacity'] / 3],
                        }}
                        color={cloning_cost[1] > selected_pod_data['sanguine_reagent'] ? 'bad' : 'good'}
                      >
                        Sanguine: {cloning_cost[1]}/{selected_pod_data['sanguine_reagent']}/
                        {selected_pod_data['max_reagent_capacity']}
                      </ProgressBar>
                    </Stack.Item>
                    <Stack.Item width="30%">
                      <ProgressBar
                        value={cloning_cost[2]}
                        maxValue={selected_pod_data['max_reagent_capacity']}
                        ranges={{
                          bad: [
                            (2 * selected_pod_data['max_reagent_capacity']) / 3,
                            selected_pod_data['max_reagent_capacity'],
                          ],
                          average: [
                            selected_pod_data['max_reagent_capacity'] / 3,
                            (2 * selected_pod_data['max_reagent_capacity']) / 3,
                          ],
                          good: [0, selected_pod_data['max_reagent_capacity'] / 3],
                        }}
                        color={cloning_cost[2] > selected_pod_data['osseous_reagent'] ? 'bad' : 'good'}
                      >
                        Osseous: {cloning_cost[2]}/{selected_pod_data['osseous_reagent']}/
                        {selected_pod_data['max_reagent_capacity']}
                      </ProgressBar>
                    </Stack.Item>
                  </Stack>
                  <LimbsMenu />
                  <OrgansMenu />
                </Box>
              )}
            </Box>
          </Section>
        </Box>
      )}
    </Box>
  );
};

const LimbsMenu = (props) => {
  const { act, data } = useBackend();
  const { patient_limb_data, limb_list, desired_limb_data } = data;
  return (
    <Collapsible title="Limbs">
      {limb_list.map((limb, i) => (
        <Box key={limb}>
          <Stack align="baseline">
            <Stack.Item color="label" width="15%" height="20px">
              {patient_limb_data[limb][4]}:{' '}
            </Stack.Item>
            <Stack.Item grow={1} />
            {patient_limb_data[limb][3] === 0 && (
              <Stack.Item width="60%">
                <ProgressBar
                  value={desired_limb_data[limb][0] + desired_limb_data[limb][1]}
                  maxValue={patient_limb_data[limb][5]}
                  ranges={{
                    good: [0, patient_limb_data[limb][5] / 3],
                    average: [patient_limb_data[limb][5] / 3, (2 * patient_limb_data[limb][5]) / 3],
                    bad: [(2 * patient_limb_data[limb][5]) / 3, patient_limb_data[limb][5]],
                  }}
                >
                  {'Post-Cloning Damage: '}
                  <Icon name="bone" />
                  {' ' + desired_limb_data[limb][0] + ' / '}
                  <Icon name="fire" />
                  {' ' + desired_limb_data[limb][1]}
                </ProgressBar>
              </Stack.Item>
            )}
            {!(patient_limb_data[limb][3] === 0) && (
              <Stack.Item width="60%">
                <ProgressBar color="bad" value={0}>
                  The patient&apos;s {patient_limb_data[limb][4]} is missing!
                </ProgressBar>
              </Stack.Item>
            )}
          </Stack>
          <Stack>
            {!!patient_limb_data[limb][3] && (
              <Stack.Item>
                <Button.Checkbox
                  checked={!desired_limb_data[limb][3]}
                  onClick={() => act('toggle_limb_repair', { limb: limb, type: 'replace' })}
                >
                  Replace Limb
                </Button.Checkbox>
              </Stack.Item>
            )}
            {!patient_limb_data[limb][3] && (
              <Stack.Item>
                <Button.Checkbox
                  disabled={!(patient_limb_data[limb][0] || patient_limb_data[limb][1])}
                  checked={!(desired_limb_data[limb][0] || desired_limb_data[limb][1])}
                  onClick={() => act('toggle_limb_repair', { limb: limb, type: 'damage' })}
                >
                  Repair Damages
                </Button.Checkbox>
                <Button.Checkbox
                  disabled={!(patient_limb_data[limb][2] & brokenFlag)}
                  checked={!(desired_limb_data[limb][2] & brokenFlag)}
                  onClick={() => act('toggle_limb_repair', { limb: limb, type: 'bone' })}
                >
                  Mend Bone
                </Button.Checkbox>
                <Button.Checkbox
                  disabled={!(patient_limb_data[limb][2] & internalBleedingFlag)}
                  checked={!(desired_limb_data[limb][2] & internalBleedingFlag)}
                  onClick={() => act('toggle_limb_repair', { limb: limb, type: 'ib' })}
                >
                  Mend IB
                </Button.Checkbox>
                <Button.Checkbox
                  disabled={!(patient_limb_data[limb][2] & burnWoundFlag)}
                  checked={!(desired_limb_data[limb][2] & burnWoundFlag)}
                  onClick={() => act('toggle_limb_repair', { limb: limb, type: 'critburn' })}
                >
                  Mend Critical Burn
                </Button.Checkbox>
              </Stack.Item>
            )}
          </Stack>
        </Box>
      ))}
    </Collapsible>
  );
};

const OrgansMenu = (props) => {
  const { act, data } = useBackend();
  const { patient_organ_data, organ_list, desired_organ_data } = data;
  return (
    <Collapsible title="Organs">
      {organ_list.map((organ, i) => (
        <Box key={organ}>
          <Stack align="baseline">
            <Stack.Item color="label" width="20%" height="20px">
              {patient_organ_data[organ][3]}:{' '}
            </Stack.Item>
            {!(patient_organ_data[organ][5] === 'heart') && (
              <Box>
                <Stack.Item>
                  {!!patient_organ_data[organ][2] && (
                    <Button.Checkbox
                      checked={!desired_organ_data[organ][2] && !desired_organ_data[organ][1]}
                      onClick={() =>
                        act('toggle_organ_repair', {
                          organ: organ,
                          type: 'replace',
                        })
                      }
                    >
                      Replace Organ
                    </Button.Checkbox>
                  )}
                  {!patient_organ_data[organ][2] && (
                    <Box>
                      <Button.Checkbox
                        disabled={!patient_organ_data[organ][0]}
                        checked={!desired_organ_data[organ][0]}
                        onClick={() =>
                          act('toggle_organ_repair', {
                            organ: organ,
                            type: 'damage',
                          })
                        }
                      >
                        Repair Damages
                      </Button.Checkbox>
                    </Box>
                  )}
                </Stack.Item>
              </Box>
            )}
            {!!(patient_organ_data[organ][5] === 'heart') && (
              <Box color="average">Heart replacement is required for cloning.</Box>
            )}
            <Stack.Item grow={1} />
            <Stack.Item width="35%">
              {!!patient_organ_data[organ][2] && (
                <ProgressBar color="bad" value={0}>
                  The patient&apos;s {patient_organ_data[organ][3]} is missing!
                </ProgressBar>
              )}
              {!patient_organ_data[organ][2] && (
                <ProgressBar
                  value={desired_organ_data[organ][0]}
                  maxValue={patient_organ_data[organ][4]}
                  ranges={{
                    good: [0, patient_organ_data[organ][4] / 3],
                    average: [patient_organ_data[organ][4] / 3, (2 * patient_organ_data[organ][4]) / 3],
                    bad: [(2 * patient_organ_data[organ][4]) / 3, patient_organ_data[organ][4]],
                  }}
                >
                  {'Post-Cloning Damage: ' + desired_organ_data[organ][0]}
                </ProgressBar>
              )}
            </Stack.Item>
          </Stack>
        </Box>
      ))}
    </Collapsible>
  );
};
