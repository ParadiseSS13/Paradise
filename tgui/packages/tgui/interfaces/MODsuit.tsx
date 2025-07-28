import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Collapsible,
  ColorBox,
  Dimmer,
  Dropdown,
  Icon,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface ModSuitData {
  active: boolean;
  malfunctioning: boolean;
  locked: boolean;
  open: boolean;
  selected_module: string | null;
  complexity: number;
  complexity_max: number;
  wearer_name: string;
  wearer_job: string;
  link_call?: string | null;
  link_id?: string | null;
  control: string;
  helmet: string | null;
  chestplate: string | null;
  gauntlets: string | null;
  boots: string | null;
  core: string | null;
  charge: number;
  ui_theme: string;
  interface_break: boolean;
  modules: ModuleData[];
}

interface Virus {
  name: string;
  type: string;
  stage: number;
  maxstage: number;
  cure: string;
}

interface ConfigData {
  display_name: string;
  type: 'number' | 'bool' | 'color' | 'list';
  key: string;
  value: any;
  values?: string[];
}

interface ModuleData {
  ref: string;
  id?: string;
  module_name: string;
  description: string;
  module_active: boolean;
  module_complexity: number;
  idle_power: number;
  active_power: number;
  use_power: number;
  cooldown: number;
  cooldown_time: number;
  module_type: number;
  pinned: boolean;
  configuration_data: Record<string, ConfigData>;
  // Health analyzer props
  userhealth?: number;
  usermaxhealth?: number;
  userbrute?: number;
  userburn?: number;
  usertoxin?: number;
  useroxy?: number;
  // Rad counter props
  userradiated?: boolean;
  usertoxins?: number;
  usermaxtoxins?: number;
  threatlevel?: number | string;
  // Status readout props
  statustime?: string;
  statusid?: string;
  statushealth?: number;
  statusmaxhealth?: number;
  statusbrute?: number;
  statusburn?: number;
  statustoxin?: number;
  statusoxy?: number;
  statustemp?: number;
  statusnutrition?: number;
  statusfingerprints?: string;
  statusdna?: string;
  statusviruses?: Virus[];
}

interface ConfigureNumberEntryProps {
  name: string;
  value: number;
  module_ref: string;
}

const ConfigureNumberEntry = (props: ConfigureNumberEntryProps) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend<ModSuitData>();
  return (
    <NumberInput
      value={value}
      minValue={-50}
      maxValue={50}
      stepPixelSize={5}
      step={1}
      width="39px"
      onChange={(value) =>
        act('configure', {
          'key': name,
          'value': value,
          'ref': module_ref,
        })
      }
    />
  );
};

interface ConfigureBoolEntryProps {
  name: string;
  value: boolean;
  module_ref: string;
}

const ConfigureBoolEntry = (props: ConfigureBoolEntryProps) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend<ModSuitData>();
  return (
    <Button.Checkbox
      checked={value}
      onClick={() =>
        act('configure', {
          'key': name,
          'value': !value,
          'ref': module_ref,
        })
      }
    />
  );
};

interface ConfigureColorEntryProps {
  name: string;
  value: string;
  module_ref: string;
}

const ConfigureColorEntry = (props: ConfigureColorEntryProps) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend<ModSuitData>();
  return (
    <>
      <Button
        icon="paint-brush"
        onClick={() =>
          act('configure', {
            'key': name,
            'ref': module_ref,
          })
        }
      />
      <ColorBox color={value} mr={0.5} />
    </>
  );
};

interface ConfigureListEntryProps {
  name: string;
  value: string;
  values: string[];
  module_ref: string;
}

const ConfigureListEntry = (props: ConfigureListEntryProps) => {
  const { name, value, values, module_ref } = props;
  const { act } = useBackend<ModSuitData>();
  return (
    <Dropdown
      displayText={value}
      options={values}
      selected={value}
      onSelected={(value) =>
        act('configure', {
          'key': name,
          'value': value,
          'ref': module_ref,
        })
      }
    />
  );
};

interface ConfigureDataEntryProps {
  name: string;
  display_name: string;
  type: 'number' | 'bool' | 'color' | 'list';
  value: any;
  values?: string[];
  module_ref: string;
}

const ConfigureDataEntry = (props: ConfigureDataEntryProps) => {
  const { name, display_name, type, value, values, module_ref } = props;
  const configureEntryTypes = {
    number: <ConfigureNumberEntry name={name} value={value} module_ref={module_ref} />,
    bool: <ConfigureBoolEntry name={name} value={value} module_ref={module_ref} />,
    color: <ConfigureColorEntry name={name} value={value} module_ref={module_ref} />,
    list: <ConfigureListEntry name={name} value={value} values={values || []} module_ref={module_ref} />,
  };
  return (
    <Box>
      {display_name}: {configureEntryTypes[type]}
    </Box>
  );
};

interface RadCounterProps {
  active: boolean;
  userradiated?: boolean;
  usertoxins?: number;
  usermaxtoxins?: number;
  threatlevel?: number | string;
}

const RadCounter = (props: RadCounterProps) => {
  const { active, userradiated, usertoxins = 0, usermaxtoxins = 100, threatlevel } = props;
  return (
    <Stack fill textAlign="center">
      <Stack.Item grow>
        <Section title="Radiation Level" color={active && userradiated ? 'bad' : 'good'}>
          {active && userradiated ? 'IRRADIATED!' : 'RADIATION-FREE'}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Toxins Level">
          <ProgressBar
            value={active ? usertoxins / usermaxtoxins : 0}
            ranges={{
              good: [-Infinity, 0.2],
              average: [0.2, 0.5],
              bad: [0.5, Infinity],
            }}
          >
            <AnimatedNumber value={usertoxins} />
          </ProgressBar>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Hazard Level" color={active && threatlevel ? 'bad' : 'good'} bold>
          {active && threatlevel ? threatlevel : 0}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

interface HealthAnalyzerProps {
  active: boolean;
  userhealth?: number;
  usermaxhealth?: number;
  userbrute?: number;
  userburn?: number;
  usertoxin?: number;
  useroxy?: number;
}

const HealthAnalyzer = (props: HealthAnalyzerProps) => {
  const {
    active,
    userhealth = 0,
    usermaxhealth = 100,
    userbrute = 0,
    userburn = 0,
    usertoxin = 0,
    useroxy = 0,
  } = props;
  return (
    <>
      <Section title="Health">
        <ProgressBar
          value={active ? userhealth / usermaxhealth : 0}
          ranges={{
            good: [0.5, Infinity],
            average: [0.2, 0.5],
            bad: [-Infinity, 0.2],
          }}
        >
          <AnimatedNumber value={active ? userhealth : 0} />
        </ProgressBar>
      </Section>
      <Stack textAlign="center">
        <Stack.Item grow>
          <Section title="Brute">
            <ProgressBar
              value={active ? userbrute / usermaxhealth : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? userbrute : 0} />
            </ProgressBar>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Burn">
            <ProgressBar
              value={active ? userburn / usermaxhealth : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? userburn : 0} />
            </ProgressBar>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Toxin">
            <ProgressBar
              value={active ? usertoxin / usermaxhealth : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? usertoxin : 0} />
            </ProgressBar>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Suffocation">
            <ProgressBar
              value={active ? useroxy / usermaxhealth : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? useroxy : 0} />
            </ProgressBar>
          </Section>
        </Stack.Item>
      </Stack>
    </>
  );
};

interface StatusReadoutProps {
  active: boolean;
  statustime?: string;
  statusid?: string;
  statushealth?: number;
  statusmaxhealth?: number;
  statusbrute?: number;
  statusburn?: number;
  statustoxin?: number;
  statusoxy?: number;
  statustemp?: number;
  statusnutrition?: number;
  statusfingerprints?: string;
  statusdna?: string;
  statusviruses?: Virus[];
}

const StatusReadout = (props: StatusReadoutProps) => {
  const {
    active,
    statustime,
    statusid,
    statushealth = 0,
    statusmaxhealth = 100,
    statusbrute = 0,
    statusburn = 0,
    statustoxin = 0,
    statusoxy = 0,
    statustemp = 0,
    statusnutrition = 0,
    statusfingerprints,
    statusdna,
    statusviruses,
  } = props;
  return (
    <>
      <Stack textAlign="center">
        <Stack.Item grow>
          <Section title="Operation Time">{active ? statustime : '00:00:00'}</Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Operation Number">{active ? statusid || '0' : '???'}</Section>
        </Stack.Item>
      </Stack>
      <Section title="Health">
        <ProgressBar
          value={active ? statushealth / statusmaxhealth : 0}
          ranges={{
            good: [0.5, Infinity],
            average: [0.2, 0.5],
            bad: [-Infinity, 0.2],
          }}
        >
          <AnimatedNumber value={active ? statushealth : 0} />
        </ProgressBar>
      </Section>
      <Stack textAlign="center">
        <Stack.Item grow>
          <Section title="Brute">
            <ProgressBar
              value={active ? statusbrute / statusmaxhealth : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? statusbrute : 0} />
            </ProgressBar>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Burn">
            <ProgressBar
              value={active ? statusburn / statusmaxhealth : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? statusburn : 0} />
            </ProgressBar>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Toxin">
            <ProgressBar
              value={active ? statustoxin / statusmaxhealth : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={statustoxin} />
            </ProgressBar>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Suffocation">
            <ProgressBar
              value={active ? statusoxy / statusmaxhealth : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={statusoxy} />
            </ProgressBar>
          </Section>
        </Stack.Item>
      </Stack>
      <Stack textAlign="center">
        <Stack.Item grow>
          <Section title="Body Temperature">{active ? statustemp : 0}</Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Nutrition Status">{active ? statusnutrition : 0}</Section>
        </Stack.Item>
      </Stack>
      <Section title="DNA">
        <LabeledList>
          <LabeledList.Item label="Fingerprints">{active ? statusfingerprints : '???'}</LabeledList.Item>
          <LabeledList.Item label="Unique Enzymes">{active ? statusdna : '???'}</LabeledList.Item>
        </LabeledList>
      </Section>
      {!!active && !!statusviruses && (
        <Section title="Diseases">
          <Table>
            <Table.Row header>
              <Table.Cell textAlign="center">
                <Button color="transparent" icon="signature" tooltip="Name" tooltipPosition="top" />
              </Table.Cell>
              <Table.Cell textAlign="center">
                <Button color="transparent" icon="wind" tooltip="Type" tooltipPosition="top" />
              </Table.Cell>
              <Table.Cell textAlign="center">
                <Button color="transparent" icon="bolt" tooltip="Stage" tooltipPosition="top" />
              </Table.Cell>
              <Table.Cell textAlign="center">
                <Button color="transparent" icon="flask" tooltip="Cure" tooltipPosition="top" />
              </Table.Cell>
            </Table.Row>
            {statusviruses.map((virus) => {
              return (
                <Table.Row key={virus.name}>
                  <Table.Cell textAlign="center">{virus.name}</Table.Cell>
                  <Table.Cell textAlign="center">{virus.type}</Table.Cell>
                  <Table.Cell textAlign="center">
                    {virus.stage}/{virus.maxstage}
                  </Table.Cell>
                  <Table.Cell textAlign="center">{virus.cure}</Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
      )}
    </>
  );
};

const ID2MODULE: Record<string, React.ComponentType<any>> = {
  rad_counter: RadCounter,
  health_analyzer: HealthAnalyzer,
  status_readout: StatusReadout,
};

const LockedInterface = () => (
  <Section align="center" fill>
    <Icon color="red" name="exclamation-triangle" size={15} />
    <Box fontSize="30px" color="red">
      ERROR: INTERFACE UNRESPONSIVE
    </Box>
  </Section>
);

const LockedModule = () => {
  return (
    <Dimmer>
      <Stack>
        <Stack.Item fontSize="16px" color="blue">
          SUIT UNPOWERED
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

interface ConfigureScreenProps {
  configuration_data: Record<string, ConfigData>;
  module_ref: string;
  onExit: () => void;
}

const ConfigureScreen = (props: ConfigureScreenProps) => {
  const { configuration_data, module_ref } = props;
  const configuration_keys = Object.keys(configuration_data);
  return (
    <Dimmer backgroundColor="rgba(0, 0, 0, 0.8)">
      <Stack vertical>
        {configuration_keys.map((key) => {
          const data = configuration_data[key];
          return (
            <Stack.Item key={data.key}>
              <ConfigureDataEntry
                name={key}
                display_name={data.display_name}
                type={data.type}
                value={data.value}
                values={data.values}
                module_ref={module_ref}
              />
            </Stack.Item>
          );
        })}
        <Stack.Item>
          <Box>
            <Button fluid onClick={props.onExit} icon="times" textAlign="center">
              Exit
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const displayText = (param?: number): string => {
  switch (param) {
    case 1:
      return 'Use';
    case 2:
      return 'Toggle';
    case 3:
      return 'Select';
    default:
      return '';
  }
};

const ParametersSection = () => {
  const { act, data } = useBackend<ModSuitData>();
  const {
    active,
    malfunctioning,
    locked,
    open,
    selected_module,
    complexity,
    complexity_max,
    wearer_name,
    wearer_job,
    link_call,
    link_id,
  } = data;
  const status = malfunctioning ? 'Malfunctioning' : active ? 'Active' : 'Inactive';
  return (
    <Section title="Parameters">
      <LabeledList>
        <LabeledList.Item
          label="Status"
          buttons={
            <Button icon="power-off" content={active ? 'Deactivate' : 'Activate'} onClick={() => act('activate')} />
          }
        >
          {status}
        </LabeledList.Item>
        <LabeledList.Item
          label="ID Lock"
          buttons={
            <Button
              icon={locked ? 'lock-open' : 'lock'}
              content={locked ? 'Unlock' : 'Lock'}
              onClick={() => act('lock')}
            />
          }
        >
          {locked ? 'Locked' : 'Unlocked'}
        </LabeledList.Item>
        <LabeledList.Item
          label="MODLink"
          buttons={
            <Button
              icon={'wifi'}
              color={link_call ? 'good' : 'default'}
              disabled={!link_id}
              content={link_call ? 'Calling (' + link_call + ')' : 'Call (' + (link_id || '') + ')'}
              onClick={() => act('call')}
            />
          }
        >
          {link_call ? 'Call Active' : 'No Active Call'}
        </LabeledList.Item>
        <LabeledList.Item label="Cover">{open ? 'Open' : 'Closed'}</LabeledList.Item>
        <LabeledList.Item label="Selected Module">{selected_module || 'None'}</LabeledList.Item>
        <LabeledList.Item label="Complexity">
          {complexity} ({complexity_max})
        </LabeledList.Item>
        <LabeledList.Item label="Occupant">
          {wearer_name}, {wearer_job}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const HardwareSection = () => {
  const { data } = useBackend<ModSuitData>();
  const { active, control, helmet, chestplate, gauntlets, boots, core, charge } = data;
  return (
    <Section title="Hardware">
      <Collapsible title="Parts">
        <LabeledList>
          <LabeledList.Item label="Control Unit">{control}</LabeledList.Item>
          <LabeledList.Item label="Helmet">{helmet || 'None'}</LabeledList.Item>
          <LabeledList.Item label="Chestplate">{chestplate || 'None'}</LabeledList.Item>
          <LabeledList.Item label="Gauntlets">{gauntlets || 'None'}</LabeledList.Item>
          <LabeledList.Item label="Boots">{boots || 'None'}</LabeledList.Item>
        </LabeledList>
      </Collapsible>
      <Collapsible title="Core">
        {(core && (
          <LabeledList>
            <LabeledList.Item label="Core Type">{core}</LabeledList.Item>
            <LabeledList.Item label="Core Charge">
              <ProgressBar
                value={charge / 100}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0.3, 0.6],
                  bad: [-Infinity, 0.3],
                }}
              >
                {charge + '%'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        )) || (
          <Box color="bad" textAlign="center">
            No Core Detected
          </Box>
        )}
      </Collapsible>
    </Section>
  );
};

const InfoSection = () => {
  const { data } = useBackend<ModSuitData>();
  const { active, modules } = data;
  const info_modules = modules.filter((module) => !!module.id);

  return (
    <Section title="Info">
      <Stack vertical>
        {(info_modules.length !== 0 &&
          info_modules.map((module) => {
            const Module = ID2MODULE[module.id || ''];
            return (
              <Stack.Item key={module.ref}>
                {!active && <LockedModule />}
                <Module {...module} active={active} />
              </Stack.Item>
            );
          })) || <Box textAlign="center">No Info Modules Detected</Box>}
      </Stack>
    </Section>
  );
};

const ModuleSection = () => {
  const { act, data } = useBackend<ModSuitData>();
  const { complexity_max, modules } = data;
  const [configureState, setConfigureState] = useState<string | null>(null);
  return (
    <Section title="Modules" fill>
      <Stack vertical>
        {(modules.length !== 0 &&
          modules.map((module) => {
            return (
              <Stack.Item key={module.ref}>
                <Collapsible title={module.module_name}>
                  <Section>
                    {configureState === module.ref && (
                      <ConfigureScreen
                        configuration_data={module.configuration_data}
                        module_ref={module.ref}
                        onExit={() => setConfigureState(null)}
                      />
                    )}
                    <Table>
                      <Table.Row header>
                        <Table.Cell textAlign="center">
                          <Button color="transparent" icon="save" tooltip="Complexity" tooltipPosition="top" />
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          <Button color="transparent" icon="plug" tooltip="Idle Power Cost" tooltipPosition="top" />
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          <Button
                            color="transparent"
                            icon="lightbulb"
                            tooltip="Active Power Cost"
                            tooltipPosition="top"
                          />
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          <Button color="transparent" icon="bolt" tooltip="Use Power Cost" tooltipPosition="top" />
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          <Button color="transparent" icon="hourglass-half" tooltip="Cooldown" tooltipPosition="top" />
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          <Button color="transparent" icon="tasks" tooltip="Actions" tooltipPosition="top" />
                        </Table.Cell>
                      </Table.Row>
                      <Table.Row>
                        <Table.Cell textAlign="center">
                          {module.module_complexity}/{complexity_max}
                        </Table.Cell>
                        <Table.Cell textAlign="center">{module.idle_power}</Table.Cell>
                        <Table.Cell textAlign="center">{module.active_power}</Table.Cell>
                        <Table.Cell textAlign="center">{module.use_power}</Table.Cell>
                        <Table.Cell textAlign="center">
                          {(module.cooldown > 0 && module.cooldown / 10) || '0'}/{module.cooldown_time / 10}s
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          <Button
                            onClick={() => act('select', { 'ref': module.ref })}
                            icon="bullseye"
                            selected={module.module_active}
                            tooltip={displayText(module.module_type)}
                            tooltipPosition="left"
                            disabled={!module.module_type}
                          />
                          <Button
                            onClick={() => setConfigureState(module.ref)}
                            icon="cog"
                            selected={configureState === module.ref}
                            tooltip="Configure"
                            tooltipPosition="left"
                            disabled={Object.keys(module.configuration_data).length === 0}
                          />
                          <Button
                            onClick={() => act('pin', { 'ref': module.ref })}
                            icon="thumbtack"
                            selected={module.pinned}
                            tooltip="Pin"
                            tooltipPosition="left"
                            disabled={!module.module_type}
                          />
                        </Table.Cell>
                      </Table.Row>
                    </Table>
                    <Box>{module.description}</Box>
                  </Section>
                </Collapsible>
              </Stack.Item>
            );
          })) || (
          <Stack.Item>
            <Box textAlign="center">No Modules Detected</Box>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

export const MODsuitContent = () => {
  const { data } = useBackend<ModSuitData>();
  const { interface_break } = data;
  return (
    <Section fill scrollable={!interface_break}>
      {(!!interface_break && <LockedInterface />) || (
        <Stack vertical>
          <Stack.Item>
            <ParametersSection />
          </Stack.Item>
          <Stack.Item>
            <HardwareSection />
          </Stack.Item>
          <Stack.Item>
            <InfoSection />
          </Stack.Item>
          <Stack.Item grow>
            <ModuleSection />
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

export const MODsuit = () => {
  const { data } = useBackend<ModSuitData>();
  const { ui_theme } = data;
  return (
    <Window theme={ui_theme} width={400} height={620}>
      <Window.Content>
        <Stack fill vertical>
          <MODsuitContent />
        </Stack>
      </Window.Content>
    </Window>
  );
};
