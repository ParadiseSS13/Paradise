import { Fragment } from "inferno";
import { useBackend, useLocalState } from "../backend";
import { Button, LabeledList, Box, AnimatedNumber, Section, ProgressBar, Icon, Tabs, Table } from "../components";
import { Window } from "../layouts";
import { InterfaceLockNoticeBox } from "./common/InterfaceLockNoticeBox";

export const AirAlarm = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    locked,
  } = data;
  // Bail straight away if there is no air
  return (
    <Window resizable>
      <Window.Content scrollable>
        <AirStatus />
        <InterfaceLockNoticeBox />
        {!locked && (
          <Fragment>
            <AirAlarmTabs />
            <AirAlarmUnlockedContent />
          </Fragment>
        )}
      </Window.Content>
    </Window>
  );
};

const Danger2Colour = danger => {
  if (danger === 0) {
    return "green";
  }
  if (danger === 1) {
    return "orange";
  }
  return "red";
};

const AirStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    air,
    mode,
    atmos_alarm,
    locked,
    alarmActivated,
    rcon,
  } = data;

  let areaStatus;
  if (air.danger.overall === 0) {
    if (atmos_alarm === 0) {
      areaStatus = "Optimal";
    } else {
      areaStatus = "Caution: Atmos alert in area";
    }
  } else if (air.danger.overall === 1) {
    areaStatus = "Caution";
  } else {
    areaStatus = "DANGER: Internals Required";
  }

  return (
    <Section title="Air Status">
      {air ? (
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <Box color={Danger2Colour(air.danger.pressure)}>
              <AnimatedNumber value={air.pressure} /> kPa
              {!locked && (
                <Fragment>
                  &nbsp;
                  <Button
                    content={mode === 3 ? "Deactivate Panic Siphon" : "Activate Panic Siphon"}
                    selected={mode === 3}
                    icon="exclamation-triangle"
                    onClick={
                      () => act('mode', { mode: (mode === 3 ? 1 : 3) })
                    } />
                </Fragment>
              )}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Oxygen">
            <ProgressBar
              value={air.contents.oxygen / 100}
              color={Danger2Colour(air.danger.oxygen)} />
          </LabeledList.Item>
          <LabeledList.Item label="Nitrogen">
            <ProgressBar
              value={air.contents.nitrogen / 100}
              color={Danger2Colour(air.danger.nitrogen)} />
          </LabeledList.Item>
          <LabeledList.Item label="Carbon Dioxide">
            <ProgressBar
              value={air.contents.co2 / 100}
              color={Danger2Colour(air.danger.co2)} />
          </LabeledList.Item>
          <LabeledList.Item label="Toxins">
            <ProgressBar
              value={air.contents.plasma / 100}
              color={Danger2Colour(air.danger.plasma)} />
          </LabeledList.Item>
          {air.contents.other > 0 && (
            <LabeledList.Item label="Other">
              <ProgressBar
                value={air.contents.other / 100}
                color={Danger2Colour(air.danger.other)} />
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Temperature">
            <Box color={Danger2Colour(air.danger.temperature)}>
              <AnimatedNumber value={air.temperature} /> K / <AnimatedNumber value={air.temperature_c} /> C&nbsp;
              <Button
                icon="thermometer-full"
                content={air.temperature_c + " C"}
                onClick={
                  () => act('temperature')
                } />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Local Status">
            <Box color={Danger2Colour(air.danger.overall)}>
              {areaStatus}
              {!locked && (
                <Fragment>
                  &nbsp;
                  <Button
                    content={alarmActivated ? "Reset Alarm" : "Activate Alarm"}
                    selected={alarmActivated}
                    onClick={
                      () => act(alarmActivated ? 'atmos_reset' : 'atmos_alarm')
                    } />
                </Fragment>
              )}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Remote Control Settings">
            <Button
              content="Off"
              selected={rcon === 1}
              onClick={
                () => act('set_rcon', { rcon: 1 })
              } />
            <Button
              content="Auto"
              selected={rcon === 2}
              onClick={
                () => act('set_rcon', { rcon: 2 })
              } />
            <Button
              content="On"
              selected={rcon === 3}
              onClick={
                () => act('set_rcon', { rcon: 3 })
              } />
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Box>
          Unable to acquire air sample!
        </Box>
      )}
    </Section>
  );
};

const AirAlarmTabs = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  return (
    <Tabs>
      <Tabs.Tab
        key="Vents"
        selected={0 === tabIndex}
        onClick={() => setTabIndex(0)}>
        <Icon name="sign-out-alt" /> Vent Control
      </Tabs.Tab>
      <Tabs.Tab
        key="Scrubbers"
        selected={1 === tabIndex}
        onClick={() => setTabIndex(1)}>
        <Icon name="sign-in-alt" /> Scrubber Control
      </Tabs.Tab>
      <Tabs.Tab
        key="Mode"
        selected={2 === tabIndex}
        onClick={() => setTabIndex(2)}>
        <Icon name="cog" /> Mode
      </Tabs.Tab>
      <Tabs.Tab
        key="Thresholds"
        selected={3 === tabIndex}
        onClick={() => setTabIndex(3)}>
        <Icon name="tachometer-alt" /> Thresholds
      </Tabs.Tab>
    </Tabs>
  );
};

const AirAlarmUnlockedContent = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
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

const AirAlarmVentsView = (props, context) => {
  const { act, data } = useBackend(context);
  const { vents } = data;
  return (
    vents.map(v => (
      <Section title={v.name} key={v.name}>
        <LabeledList>
          <LabeledList.Item label="Status">
            <Button
              content={v.power ? "On" : "Off"}
              selected={v.power}
              icon="power-off"
              onClick={
                () => act('command', { cmd: 'power', val: (v.power === 1 ? 0 : 1), id_tag: v.id_tag })
              } />
            <Button
              content={v.direction === "release" ? "Blowing" : "Siphoning"}
              icon={v.direction === "release" ? "sign-out-alt" : "sign-in-alt"}
              onClick={
                () => act('command', { cmd: 'direction', val: (v.direction === "release" ? 0 : 1), id_tag: v.id_tag })
              } />
          </LabeledList.Item>
          <LabeledList.Item label="Pressure Checks">
            <Button
              content="External"
              selected={v.checks === 1}
              onClick={
                () => act('command', { cmd: 'checks', val: 1, id_tag: v.id_tag })
              } />
            <Button
              content="Internal"
              selected={v.checks === 2}
              onClick={
                () => act('command', { cmd: 'checks', val: 2, id_tag: v.id_tag })
              } />
          </LabeledList.Item>
          <LabeledList.Item label="External Pressure Target">
            <AnimatedNumber value={v.external} /> kPa&nbsp;
            <Button
              content="Set"
              icon="cog"
              onClick={
                () => act('command', { cmd: 'set_external_pressure', id_tag: v.id_tag })
              } />
            <Button
              content="Reset"
              icon="redo-alt"
              onClick={
                () => act('command', { cmd: 'set_external_pressure', val: 101.325, id_tag: v.id_tag })
              } />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    ))
  );
};

const AirAlarmScrubbersView = (props, context) => {
  const { act, data } = useBackend(context);
  const { scrubbers } = data;
  return (
    scrubbers.map(s => (
      <Section title={s.name} key={s.name}>
        <LabeledList>
          <LabeledList.Item label="Status">
            <Button
              content={s.power ? "On" : "Off"}
              selected={s.power}
              icon="power-off"
              onClick={
                () => act('command', { cmd: 'power', val: (s.power === 1 ? 0 : 1), id_tag: s.id_tag })
              } />
            <Button
              content={s.scrubbing === 0 ? "Siphoning" : "Scrubbing"}
              icon={s.scrubbing === 0 ? "sign-in-alt" : "filter"}
              onClick={
                () => act('command', { cmd: 'scrubbing', val: (s.scrubbing === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
          </LabeledList.Item>
          <LabeledList.Item label="Range">
            <Button
              content={s.widenet ? "Extended" : "Normal"}
              selected={s.widenet}
              icon="expand-arrows-alt"
              onClick={
                () => act('command', { cmd: 'widenet', val: (s.widenet === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
          </LabeledList.Item>
          <LabeledList.Item label="Filtering">
            <Button
              content="Cargon Dioxide"
              selected={s.filter_co2}
              onClick={
                () => act('command', { cmd: 'co2_scrub', val: (s.filter_co2 === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
            <Button
              content="Plasma"
              selected={s.filter_toxins}
              onClick={
                () => act('command', { cmd: 'tox_scrub', val: (s.filter_toxins === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
            <Button
              content="Nitrous Oxide"
              selected={s.filter_n2o}
              onClick={
                () => act('command', { cmd: 'n2o_scrub', val: (s.filter_n2o === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
            <Button
              content="Oxygen"
              selected={s.filter_o2}
              onClick={
                () => act('command', { cmd: 'o2_scrub', val: (s.filter_o2 === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
            <Button
              content="Nitrogen"
              selected={s.filter_n2}
              onClick={
                () => act('command', { cmd: 'n2_scrub', val: (s.filter_n2 === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    ))
  );
};

const AirAlarmModesView = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    modes,
    presets,
    emagged,
    mode,
    preset,
  } = data;
  return (
    <Fragment>
      <Section title="System Mode">
        <Table>
          {modes.map(m => (
            (!m.emagonly || m.emagonly && !!emagged) && (
              <Table.Row key={m.name}>
                <Table.Cell textAlign="right" width={1}>
                  <Button content={m.name} icon="cog" selected={m.id === mode} onClick={
                    () => act('mode', { mode: m.id })
                  } />
                </Table.Cell>
                <Table.Cell>
                  {m.desc}
                </Table.Cell>
              </Table.Row>
            )
          ))}
        </Table>
      </Section>
      <Section title="System Presets">
        <Box italic>
          After making a selection, the system will automatically cycle in order to remove contaminants.
        </Box>
        <Table mt={1}>
          {presets.map(p => (
            <Table.Row key={p.name}>
              <Table.Cell textAlign="right" width={1}>
                <Button content={p.name} icon="cog" selected={p.id === preset} onClick={
                  () => act('preset', { preset: p.id })
                } />
              </Table.Cell>
              <Table.Cell>
                {p.desc}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Fragment>
  );
};


const AirAlarmThresholdsView = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    thresholds,
  } = data;
  return (
    <Section title="Alarm Thresholds">
      <Table>
        <Table.Row header>
          <Table.Cell width="20%">
            Value
          </Table.Cell>
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
        {thresholds.map(t => (
          <Table.Row key={t.name}>
            <Table.Cell>
              {t.name}
            </Table.Cell>
            {t.settings.map(s => (
              <Table.Cell key={s.val}>
                <Button content={s.selected === -1 ? "Off" : s.selected} onClick={
                  () => act('command', { cmd: 'set_threshold', env: s.env, var: s.val })
                } />
              </Table.Cell>
            ))}
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
