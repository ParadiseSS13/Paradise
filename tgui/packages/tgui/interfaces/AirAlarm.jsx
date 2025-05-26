import { useContext } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';
import TabsContext from './common/TabsContext';

export const AirAlarm = (props) => {
  const { act, data } = useBackend();
  const { locked } = data;
  // Bail straight away if there is no air
  return (
    <Window width={570} height={locked ? 310 : 755}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox />
        <AirStatus />
        {!locked && (
          <TabsContext.Default tabIndex={0}>
            <AirAlarmTabs />
            <AirAlarmUnlockedContent />
          </TabsContext.Default>
        )}
      </Window.Content>
    </Window>
  );
};

const Danger2Colour = (danger) => {
  if (danger === 0) {
    return 'green';
  }
  if (danger === 1) {
    return 'orange';
  }
  return 'red';
};

const AirStatus = (props) => {
  const { act, data } = useBackend();
  const { air, mode, atmos_alarm, locked, alarmActivated, rcon, target_temp } = data;

  let areaStatus;
  if (air.danger.overall === 0) {
    if (atmos_alarm === 0) {
      areaStatus = 'Optimal';
    } else {
      areaStatus = 'Caution: Atmos alert in area';
    }
  } else if (air.danger.overall === 1) {
    areaStatus = 'Caution';
  } else {
    areaStatus = 'DANGER: Internals Required';
  }

  return (
    <Section title="Air Status">
      {air ? (
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <Box color={Danger2Colour(air.danger.pressure)}>
              <AnimatedNumber value={air.pressure} /> kPa
              {!locked && (
                <>
                  &nbsp;
                  <Button
                    content={mode === 3 ? 'Deactivate Panic Siphon' : 'Activate Panic Siphon'}
                    selected={mode === 3}
                    icon="exclamation-triangle"
                    onClick={() => act('mode', { mode: mode === 3 ? 1 : 3 })}
                  />
                </>
              )}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Oxygen">
            <ProgressBar
              value={air.contents.oxygen / 100}
              fractionDigits="1"
              color={Danger2Colour(air.danger.oxygen)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Nitrogen">
            <ProgressBar
              value={air.contents.nitrogen / 100}
              fractionDigits="1"
              color={Danger2Colour(air.danger.nitrogen)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Carbon Dioxide">
            <ProgressBar value={air.contents.co2 / 100} fractionDigits="1" color={Danger2Colour(air.danger.co2)} />
          </LabeledList.Item>
          <LabeledList.Item label="Toxins">
            <ProgressBar
              value={air.contents.plasma / 100}
              fractionDigits="1"
              color={Danger2Colour(air.danger.plasma)}
            />
          </LabeledList.Item>
          {air.contents.n2o > 0.1 && (
            <LabeledList.Item label="Nitrous Oxide">
              <ProgressBar value={air.contents.n2o / 100} fractionDigits="1" color={Danger2Colour(air.danger.n2o)} />
            </LabeledList.Item>
          )}
          {air.contents.other > 0.1 && (
            <LabeledList.Item label="Other">
              <ProgressBar
                value={air.contents.other / 100}
                fractionDigits="1"
                color={Danger2Colour(air.danger.other)}
              />
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Temperature">
            <Box color={Danger2Colour(air.danger.temperature)}>
              <AnimatedNumber value={air.temperature} /> K / <AnimatedNumber value={air.temperature_c} /> C&nbsp;
              <Button icon="thermometer-full" content={target_temp + ' C'} onClick={() => act('temperature')} />
              <Button
                content={air.thermostat_state ? 'On' : 'Off'}
                selected={air.thermostat_state}
                icon="power-off"
                onClick={() => act('thermostat_state')}
              />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Local Status">
            <Box color={Danger2Colour(air.danger.overall)}>
              {areaStatus}
              {!locked && (
                <>
                  &nbsp;
                  <Button
                    content={alarmActivated ? 'Reset Alarm' : 'Activate Alarm'}
                    selected={alarmActivated}
                    onClick={() => act(alarmActivated ? 'atmos_reset' : 'atmos_alarm')}
                  />
                </>
              )}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Remote Control Settings">
            <Button content="Off" selected={rcon === 1} onClick={() => act('set_rcon', { rcon: 1 })} />
            <Button content="Auto" selected={rcon === 2} onClick={() => act('set_rcon', { rcon: 2 })} />
            <Button content="On" selected={rcon === 3} onClick={() => act('set_rcon', { rcon: 3 })} />
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Box>Unable to acquire air sample!</Box>
      )}
    </Section>
  );
};

const AirAlarmTabs = (props) => {
  const { tabIndex, setTabIndex } = useContext(TabsContext);
  return (
    <Tabs>
      <Tabs.Tab key="Vents" selected={0 === tabIndex} onClick={() => setTabIndex(0)}>
        <Icon name="sign-out-alt" /> Vent Control
      </Tabs.Tab>
      <Tabs.Tab key="Scrubbers" selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
        <Icon name="sign-in-alt" /> Scrubber Control
      </Tabs.Tab>
      <Tabs.Tab key="Mode" selected={2 === tabIndex} onClick={() => setTabIndex(2)}>
        <Icon name="cog" /> Mode
      </Tabs.Tab>
      <Tabs.Tab key="Thresholds" selected={3 === tabIndex} onClick={() => setTabIndex(3)}>
        <Icon name="tachometer-alt" /> Thresholds
      </Tabs.Tab>
    </Tabs>
  );
};

const AirAlarmUnlockedContent = (props) => {
  const { tabIndex } = useContext(TabsContext);
  switch (tabIndex) {
    case 0:
      return <AirAlarmVentsView />;
    case 1:
      return <AirAlarmScrubbersView />;
    case 2:
      return <AirAlarmModesView />;
    case 3:
      return <AirAlarmThresholdsView />;
    default:
      return "WE SHOULDN'T BE HERE!";
  }
};

const AirAlarmVentsView = (props) => {
  const { act, data } = useBackend();
  const { vents } = data;
  return vents.map((v) => (
    <Section title={v.name} key={v.name}>
      <LabeledList>
        <LabeledList.Item label="Status">
          <Button
            content={v.power ? 'On' : 'Off'}
            selected={v.power}
            icon="power-off"
            onClick={() =>
              act('command', {
                cmd: 'power',
                val: !v.power,
                id_tag: v.id_tag,
              })
            }
          />
          <Button
            content={v.direction ? 'Blowing' : 'Siphoning'}
            icon={v.direction ? 'sign-out-alt' : 'sign-in-alt'}
            onClick={() =>
              act('command', {
                cmd: 'direction',
                val: !v.direction,
                id_tag: v.id_tag,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Pressure Checks">
          <Button
            content="External"
            selected={v.checks === 1}
            onClick={() => act('command', { cmd: 'checks', val: 1, id_tag: v.id_tag })}
          />
          <Button
            content="Internal"
            selected={v.checks === 2}
            onClick={() => act('command', { cmd: 'checks', val: 2, id_tag: v.id_tag })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="External Pressure Target">
          <AnimatedNumber value={v.external} /> kPa&nbsp;
          <Button
            content="Set"
            icon="cog"
            onClick={() => act('command', { cmd: 'set_external_pressure', id_tag: v.id_tag })}
          />
          <Button
            content="Reset"
            icon="redo-alt"
            onClick={() =>
              act('command', {
                cmd: 'set_external_pressure',
                val: 101.325,
                id_tag: v.id_tag,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  ));
};

const AirAlarmScrubbersView = (props) => {
  const { act, data } = useBackend();
  const { scrubbers } = data;
  return scrubbers.map((s) => (
    <Section title={s.name} key={s.name}>
      <LabeledList>
        <LabeledList.Item label="Status">
          <Button
            content={s.power ? 'On' : 'Off'}
            selected={s.power}
            icon="power-off"
            onClick={() =>
              act('command', {
                cmd: 'power',
                val: !s.power,
                id_tag: s.id_tag,
              })
            }
          />
          <Button
            content={s.scrubbing ? 'Scrubbing' : 'Siphoning'}
            icon={s.scrubbing ? 'filter' : 'sign-in-alt'}
            onClick={() =>
              act('command', {
                cmd: 'scrubbing',
                val: !s.scrubbing,
                id_tag: s.id_tag,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Range">
          <Button
            content={s.widenet ? 'Extended' : 'Normal'}
            selected={s.widenet}
            icon="expand-arrows-alt"
            onClick={() =>
              act('command', {
                cmd: 'widenet',
                val: !s.widenet,
                id_tag: s.id_tag,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Filtering">
          <Button
            content="Carbon Dioxide"
            selected={s.filter_co2}
            onClick={() =>
              act('command', {
                cmd: 'co2_scrub',
                val: !s.filter_co2,
                id_tag: s.id_tag,
              })
            }
          />
          <Button
            content="Plasma"
            selected={s.filter_toxins}
            onClick={() =>
              act('command', {
                cmd: 'tox_scrub',
                val: !s.filter_toxins,
                id_tag: s.id_tag,
              })
            }
          />
          <Button
            content="Nitrous Oxide"
            selected={s.filter_n2o}
            onClick={() =>
              act('command', {
                cmd: 'n2o_scrub',
                val: !s.filter_n2o,
                id_tag: s.id_tag,
              })
            }
          />
          <Button
            content="Oxygen"
            selected={s.filter_o2}
            onClick={() =>
              act('command', {
                cmd: 'o2_scrub',
                val: !s.filter_o2,
                id_tag: s.id_tag,
              })
            }
          />
          <Button
            content="Nitrogen"
            selected={s.filter_n2}
            onClick={() =>
              act('command', {
                cmd: 'n2_scrub',
                val: !s.filter_n2,
                id_tag: s.id_tag,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  ));
};

const AirAlarmModesView = (props) => {
  const { act, data } = useBackend();
  const { modes, presets, emagged, mode, preset } = data;
  return (
    <>
      <Section title="System Mode">
        {Object.keys(modes).map((key) => {
          let m = modes[key];
          if (!m.emagonly || !!emagged) {
            return (
              <Table.Row key={m.name}>
                <Table.Cell textAlign="right" width={1}>
                  <Button
                    content={m.name}
                    icon="cog"
                    selected={m.id === mode}
                    onClick={() => act('mode', { mode: m.id })}
                  />
                </Table.Cell>
                <Table.Cell>{m.desc}</Table.Cell>
              </Table.Row>
            );
          }
        })}
      </Section>
      <Section title="System Presets">
        <Box italic>After making a selection, the system will automatically cycle in order to remove contaminants.</Box>
        <Table mt={1}>
          {presets.map((p) => (
            <Table.Row key={p.name}>
              <Table.Cell textAlign="right" width={1}>
                <Button
                  content={p.name}
                  icon="cog"
                  selected={p.id === preset}
                  onClick={() => act('preset', { preset: p.id })}
                />
              </Table.Cell>
              <Table.Cell>{p.desc}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </>
  );
};

const AirAlarmThresholdsView = (props) => {
  const { act, data } = useBackend();
  const { thresholds } = data;
  return (
    <Section title="Alarm Thresholds">
      <Table>
        <Table.Row header>
          <Table.Cell width="20%">Value</Table.Cell>
          <Table.Cell color="red" width="20%">
            Danger Min
          </Table.Cell>
          <Table.Cell color="orange" width="20%">
            Warning Min
          </Table.Cell>
          <Table.Cell color="orange" width="20%">
            Warning Max
          </Table.Cell>
          <Table.Cell color="red" width="20%">
            Danger Max
          </Table.Cell>
        </Table.Row>
        {thresholds.map((t) => (
          <Table.Row key={t.name}>
            <Table.Cell>{t.name}</Table.Cell>
            {t.settings.map((s) => (
              <Table.Cell key={s.val}>
                <Button
                  content={s.selected === -1 ? 'Off' : s.selected}
                  onClick={() =>
                    act('command', {
                      cmd: 'set_threshold',
                      env: s.env,
                      var: s.val,
                    })
                  }
                />
              </Table.Cell>
            ))}
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
