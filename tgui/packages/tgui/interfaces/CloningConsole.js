import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section, Box, Tabs, Flex } from '../components';
import { Window } from '../layouts';

export const CloningConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    tab,
    hasScanner,
    podAmount
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title='Cloning Console'>
          <LabeledList>
            <LabeledList.Item label="Connected scanner">{hasScanner ? 'Online' : 'Missing'}</LabeledList.Item>
            <LabeledList.Item label="Connected pods">{podAmount}</LabeledList.Item>
          </LabeledList>
        </Section>
        <Tabs>
          <Tabs.Tab selected={tab === 1} icon="home" onClick={() => act('menu', {tab: 1})}>Main Menu</Tabs.Tab>
          <Tabs.Tab selected={tab === 2} icon="user" onClick={() => act('menu', {tab: 2})}>Damage Configuration</Tabs.Tab>
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
  const {
    pods,
    selectedPodUID
  } = data;
  return (
    <Box>
      {!pods && (<Box color='average'>Notice: No pods connected.</Box>)}
      {!!pods &&
        pods.map((pod, i) => (
          <Section key={pod} layer={2} title={"Pod " + (i + 1)}>
            <Flex textAlign='center'>
              <Flex.Item basis="96px" shrink={0}>
                <img
                  src={'pod_' + (pod["cloning"] ? 'cloning' : 'idle') + '.gif'}
                  style={{
                  width: '100%',
                    '-ms-interpolation-mode': 'nearest-neighbor',
                  }}
                />
                <Button selected={selectedPodUID === pod["uid"]} onClick={() => act('select_pod', {uid: pod["uid"]})}>
                  Select
                </Button>
              </Flex.Item>
              <Flex.Item>
                <LabeledList>
                  <LabeledList.Item label='Progress'>
                    {!pod["currently_cloning"] && <Box color='average'>Pod is inactive.</Box>}
                    {!!pod["currently_cloning"] && <ProgressBar value={pod["clone_progress"]}
                      maxValue={100}
                      color='good' />}
                  </LabeledList.Item>
                  <LabeledList.Divider />
                  <LabeledList.Item label='Biomass'>
                    <ProgressBar value={pod["biomass"]}
                      ranges={{
                        good: [(2*pod["biomass_storage_capacity"])/3, pod["biomass_storage_capacity"]],
                        average: [pod["biomass_storage_capacity"]/3, (2*pod["biomass_storage_capacity"])/3],
                        bad: [0, pod["biomass_storage_capacity"]/3] // This is just thirds again
                      }}
                      minValue={0}
                      maxValue={pod["biomass_storage_capacity"]}>
                      {pod["biomass"]}/{pod["biomass_storage_capacity"] + " (" + 100*pod["biomass"]/pod["biomass_storage_capacity"] + "%)"}
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item label='Sanguine Reagent'>{pod["sanguine_reagent"]}</LabeledList.Item>
                  <LabeledList.Item label='Osseous Reagent'>{pod["osseous_reagent"]}</LabeledList.Item>
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
    patientLimbData,
    patientOrganData
  } = data;
  return (
    <Box>
      <Section layer={2} title='Scanner Info' buttons={<Button icon="hourglass-half" onClick={() => act('scan')}>
        Scan
      </Button>}>
        {!hasScanned && <Box color='average'>No scan detected for current patient.</Box>}
      </Section>
      <Section layer={2} title='Damages Breakdown'>
        filler text :3
      </Section>
    </Box>
  );
};
