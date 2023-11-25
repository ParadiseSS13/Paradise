import { useBackend, useLocalState } from '../backend';
import {
  Button,
  ColorBox,
  LabeledList,
  ProgressBar,
  Section,
  Collapsible,
  Box,
  Icon,
  Flex,
  Table,
  Dimmer,
  NumberInput,
  AnimatedNumber,
  Dropdown,
} from '../components';
import { Window } from '../layouts';

const ConfigureNumberEntry = (props, context) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend(context);
  return (
    <NumberInput
      value={value}
      minValue={-50}
      maxValue={50}
      stepPixelSize={5}
      width="39px"
      onChange={(e, value) =>
        act('configure', {
          'key': name,
          'value': value,
          'ref': module_ref,
        })
      }
    />
  );
};

const ConfigureBoolEntry = (props, context) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend(context);
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

const ConfigureColorEntry = (props, context) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend(context);
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

const ConfigureListEntry = (props, context) => {
  const { name, value, values, module_ref } = props;
  const { act } = useBackend(context);
  return (
    <Dropdown
      displayText={value}
      options={values}
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

const ConfigureDataEntry = (props, context) => {
  const { name, display_name, type, value, values, module_ref } = props;
  const configureEntryTypes = {
    number: <ConfigureNumberEntry {...props} />,
    bool: <ConfigureBoolEntry {...props} />,
    color: <ConfigureColorEntry {...props} />,
    list: <ConfigureListEntry {...props} />,
  };
  return (
    <Box>
      {display_name}: {configureEntryTypes[type]}
    </Box>
  );
};

const RadCounter = (props, context) => {
  const { active, userradiated, usertoxins, usermaxtoxins, threatlevel } =
    props;
  return (
    <Flex fill textAlign="center">
      <Flex.Item grow>
        <Section
          title="Radiation Level"
          color={active && userradiated ? 'bad' : 'good'}
        >
          {active && userradiated ? 'IRRADIATED!' : 'RADIATION-FREE'}
        </Section>
      </Flex.Item>
      <Flex.Item grow>
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
      </Flex.Item>
      <Flex.Item grow>
        <Section
          title="Hazard Level"
          color={active && threatlevel ? 'bad' : 'good'}
          bold
        >
          {active && threatlevel ? threatlevel : 0}
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const HealthAnalyzer = (props, context) => {
  const {
    active,
    userhealth,
    usermaxhealth,
    userbrute,
    userburn,
    usertoxin,
    useroxy,
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
      <Flex textAlign="center">
        <Flex.Item grow>
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
        </Flex.Item>
        <Flex.Item grow>
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
        </Flex.Item>
        <Flex.Item grow>
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
        </Flex.Item>
        <Flex.Item grow>
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
        </Flex.Item>
      </Flex>
    </>
  );
};

const StatusReadout = (props, context) => {
  const {
    active,
    statustime,
    statusid,
    statushealth,
    statusmaxhealth,
    statusbrute,
    statusburn,
    statustoxin,
    statusoxy,
    statustemp,
    statusnutrition,
    statusfingerprints,
    statusdna,
    statusviruses,
  } = props;
  return (
    <>
      <Flex textAlign="center">
        <Flex.Item grow>
          <Section title="Operation Time">
            {active ? statustime : '00:00:00'}
          </Section>
        </Flex.Item>
        <Flex.Item grow>
          <Section title="Operation Number">
            {active ? statusid || '0' : '???'}
          </Section>
        </Flex.Item>
      </Flex>
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
      <Flex textAlign="center">
        <Flex.Item grow>
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
        </Flex.Item>
        <Flex.Item grow>
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
        </Flex.Item>
        <Flex.Item grow>
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
        </Flex.Item>
        <Flex.Item grow>
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
        </Flex.Item>
      </Flex>
      <Flex textAlign="center">
        <Flex.Item grow>
          <Section title="Body Temperature">{active ? statustemp : 0}</Section>
        </Flex.Item>
        <Flex.Item grow>
          <Section title="Nutrition Status">
            {active ? statusnutrition : 0}
          </Section>
        </Flex.Item>
      </Flex>
      <Section title="DNA">
        <LabeledList>
          <LabeledList.Item label="Fingerprints">
            {active ? statusfingerprints : '???'}
          </LabeledList.Item>
          <LabeledList.Item label="Unique Enzymes">
            {active ? statusdna : '???'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      {!!active && !!statusviruses && (
        <Section title="Diseases">
          <Table>
            <Table.Row header>
              <Table.Cell textAlign="center">
                <Button
                  color="transparent"
                  icon="signature"
                  tooltip="Name"
                  tooltipPosition="top"
                />
              </Table.Cell>
              <Table.Cell textAlign="center">
                <Button
                  color="transparent"
                  icon="wind"
                  tooltip="Type"
                  tooltipPosition="top"
                />
              </Table.Cell>
              <Table.Cell textAlign="center">
                <Button
                  color="transparent"
                  icon="bolt"
                  tooltip="Stage"
                  tooltipPosition="top"
                />
              </Table.Cell>
              <Table.Cell textAlign="center">
                <Button
                  color="transparent"
                  icon="flask"
                  tooltip="Cure"
                  tooltipPosition="top"
                />
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

const ID2MODULE = {
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

const LockedModule = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Dimmer>
      <Flex>
        <Flex.Item fontSize="16px" color="blue">
          SUIT UNPOWERED
        </Flex.Item>
      </Flex>
    </Dimmer>
  );
};

const ConfigureScreen = (props, context) => {
  const { configuration_data, module_ref } = props;
  const configuration_keys = Object.keys(configuration_data);
  return (
    <Dimmer backgroundColor="rgba(0, 0, 0, 0.8)">
      <Flex direction="column">
        {configuration_keys.map((key) => {
          const data = configuration_data[key];
          return (
            <Flex.Item key={data.key}>
              <ConfigureDataEntry
                name={key}
                display_name={data.display_name}
                type={data.type}
                value={data.value}
                values={data.values}
                module_ref={module_ref}
              />
            </Flex.Item>
          );
        })}
        <Flex.Item>
          <Box>
            <Button
              fluid
              onClick={props.onExit}
              icon="times"
              textAlign="center"
            >
              Exit
            </Button>
          </Box>
        </Flex.Item>
      </Flex>
    </Dimmer>
  );
};

const displayText = (param) => {
  switch (param) {
    case 1:
      return 'Use';
    case 2:
      return 'Toggle';
    case 3:
      return 'Select';
  }
};

const ParametersSection = (props, context) => {
  const { act, data } = useBackend(context);
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
  } = data;
  const status = malfunctioning
    ? 'Malfunctioning'
    : active
    ? 'Active'
    : 'Inactive';
  return (
    <Section title="Parameters">
      <LabeledList>
        <LabeledList.Item
          label="Status"
          buttons={
            <Button
              icon="power-off"
              content={active ? 'Deactivate' : 'Activate'}
              onClick={() => act('activate')}
            />
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
        <LabeledList.Item label="Cover">
          {open ? 'Open' : 'Closed'}
        </LabeledList.Item>
        <LabeledList.Item label="Selected Module">
          {selected_module || 'None'}
        </LabeledList.Item>
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

const HardwareSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active,
    control,
    helmet,
    chestplate,
    gauntlets,
    boots,
    core,
    charge,
  } = data;
  return (
    <Section title="Hardware">
      <Collapsible title="Parts">
        <LabeledList>
          <LabeledList.Item label="Control Unit">{control}</LabeledList.Item>
          <LabeledList.Item label="Helmet">{helmet || 'None'}</LabeledList.Item>
          <LabeledList.Item label="Chestplate">
            {chestplate || 'None'}
          </LabeledList.Item>
          <LabeledList.Item label="Gauntlets">
            {gauntlets || 'None'}
          </LabeledList.Item>
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
                content={charge + '%'}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0.3, 0.6],
                  bad: [-Infinity, 0.3],
                }}
              />
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

const InfoSection = (props, context) => {
  const { act, data } = useBackend(context);
  const { active, modules } = data;
  const info_modules = modules.filter((module) => !!module.id);

  return (
    <Section title="Info">
      <Flex direction="column">
        {(info_modules.length !== 0 &&
          info_modules.map((module) => {
            const Module = ID2MODULE[module.id];
            return (
              <Flex.Item key={module.ref}>
                {!active && <LockedModule />}
                <Module {...module} active={active} />
              </Flex.Item>
            );
          })) || <Box textAlign="center">No Info Modules Detected</Box>}
      </Flex>
    </Section>
  );
};

const ModuleSection = (props, context) => {
  const { act, data } = useBackend(context);
  const { complexity_max, modules } = data;
  const [configureState, setConfigureState] = useLocalState(
    context,
    'module_configuration',
    null
  );
  return (
    <Section title="Modules" fill>
      <Flex direction="column">
        {(modules.length !== 0 &&
          modules.map((module) => {
            return (
              <Flex.Item key={module.ref}>
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
                          <Button
                            color="transparent"
                            icon="save"
                            tooltip="Complexity"
                            tooltipPosition="top"
                          />
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          <Button
                            color="transparent"
                            icon="plug"
                            tooltip="Idle Power Cost"
                            tooltipPosition="top"
                          />
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
                          <Button
                            color="transparent"
                            icon="bolt"
                            tooltip="Use Power Cost"
                            tooltipPosition="top"
                          />
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          <Button
                            color="transparent"
                            icon="hourglass-half"
                            tooltip="Cooldown"
                            tooltipPosition="top"
                          />
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          <Button
                            color="transparent"
                            icon="tasks"
                            tooltip="Actions"
                            tooltipPosition="top"
                          />
                        </Table.Cell>
                      </Table.Row>
                      <Table.Row>
                        <Table.Cell textAlign="center">
                          {module.module_complexity}/{complexity_max}
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          {module.idle_power}
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          {module.active_power}
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          {module.use_power}
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          {(module.cooldown > 0 && module.cooldown / 10) || '0'}
                          /{module.cooldown_time / 10}s
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
                            disabled={module.configuration_data.length === 0}
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
              </Flex.Item>
            );
          })) || (
          <Flex.Item>
            <Box textAlign="center">No Modules Detected</Box>
          </Flex.Item>
        )}
      </Flex>
    </Section>
  );
};

export const MODsuitContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { ui_theme, interface_break } = data;
  return (
    <Section>
      {(!!interface_break && <LockedInterface />) || (
        <Flex direction="column">
          <Flex.Item>
            <ParametersSection />
          </Flex.Item>
          <Flex.Item>
            <HardwareSection />
          </Flex.Item>
          <Flex.Item>
            <InfoSection />
          </Flex.Item>
          <Flex.Item grow>
            <ModuleSection />
          </Flex.Item>
        </Flex>
      )}
    </Section>
  );
};

export const MODsuit = (props, context) => {
  const { act, data } = useBackend(context);
  const { ui_theme, interface_break } = data;
  return (
    <Window theme={ui_theme} resizable>
      <Window.Content scrollable={!interface_break}>
        <MODsuitContent />
      </Window.Content>
    </Window>
  );
};
