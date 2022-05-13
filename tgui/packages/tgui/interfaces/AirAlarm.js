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
    target_temp,
  } = data;

  let areaStatus;
  if (air.danger.overall === 0) {
    if (atmos_alarm === 0) {
      areaStatus = "Оптимум";
    } else {
      areaStatus = "Внимание: Атмосферная тревога";
    }
  } else if (air.danger.overall === 1) {
    areaStatus = "Внимание";
  } else {
    areaStatus = "ОПАСНОСТЬ: Непригодно для дыхания";
  }

  return (
    <Section title="Состав воздуха">
      {air ? (
        <LabeledList>
          <LabeledList.Item label="Давление">
            <Box color={Danger2Colour(air.danger.pressure)}>
              <AnimatedNumber value={air.pressure} /> кПа
              {!locked && (
                <Fragment>
                  &nbsp;
                  <Button
                    content={mode === 3 ? "Остановить откачку" : "Экстренная откачка"}
                    selected={mode === 3}
                    icon="exclamation-triangle"
                    onClick={
                      () => act('mode', { mode: (mode === 3 ? 1 : 3) })
                    } />
                </Fragment>
              )}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Кислород">
            <ProgressBar
              value={air.contents.oxygen / 100}
              color={Danger2Colour(air.danger.oxygen)} />
          </LabeledList.Item>
          <LabeledList.Item label="Азот">
            <ProgressBar
              value={air.contents.nitrogen / 100}
              color={Danger2Colour(air.danger.nitrogen)} />
          </LabeledList.Item>
          <LabeledList.Item label="Двуокись углерода">
            <ProgressBar
              value={air.contents.co2 / 100}
              color={Danger2Colour(air.danger.co2)} />
          </LabeledList.Item>
          <LabeledList.Item label="Токсины">
            <ProgressBar
              value={air.contents.plasma / 100}
              color={Danger2Colour(air.danger.plasma)} />
          </LabeledList.Item>
          {air.contents.other > 0 && (
            <LabeledList.Item label="Прочее">
              <ProgressBar
                value={air.contents.other / 100}
                color={Danger2Colour(air.danger.other)} />
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Термостат">
            <Box color={Danger2Colour(air.danger.temperature)}>
              <AnimatedNumber value={air.temperature} />&nbsp;K / <AnimatedNumber value={air.temperature_c} />&nbsp;°C&nbsp;
              <Button
                icon="thermometer-full"
                content={target_temp + " °C"}
                onClick={
                  () => act('temperature')
                } />
              <Button
                content={air.thermostat_state ? "Вкл" : "Выкл"}
                selected={air.thermostat_state}
                icon="power-off"
                onClick={
                  () => act('thermostat_state')
                } />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Статус помещения">
            <Box color={Danger2Colour(air.danger.overall)}>
              {`${areaStatus} `}
              {!locked && (
                <Button
                  content={alarmActivated ? "Сбросить тревогу" : "Активировать тревогу"}
                  selected={alarmActivated}
                  onClick={
                    () => act(alarmActivated ? 'atmos_reset' : 'atmos_alarm')
                  } />
              )}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Удалённое управление">
            <Button
              content="Выкл"
              selected={rcon === 1}
              onClick={
                () => act('set_rcon', { rcon: 1 })
              } />
            <Button
              content="Авто"
              selected={rcon === 2}
              onClick={
                () => act('set_rcon', { rcon: 2 })
              } />
            <Button
              content="Вкл"
              selected={rcon === 3}
              onClick={
                () => act('set_rcon', { rcon: 3 })
              } />
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Box>
          Невозможно получить образец воздуха!
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
        <Icon name="sign-out-alt" /> Вентиляция
      </Tabs.Tab>
      <Tabs.Tab
        key="Scrubbers"
        selected={1 === tabIndex}
        onClick={() => setTabIndex(1)}>
        <Icon name="sign-in-alt" /> Вытяжки
      </Tabs.Tab>
      <Tabs.Tab
        key="Mode"
        selected={2 === tabIndex}
        onClick={() => setTabIndex(2)}>
        <Icon name="cog" /> Режим
      </Tabs.Tab>
      <Tabs.Tab
        key="Thresholds"
        selected={3 === tabIndex}
        onClick={() => setTabIndex(3)}>
        <Icon name="tachometer-alt" /> Пороги
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
          <LabeledList.Item label="Статус">
            <Button
              content={v.power ? "Вкл" : "Выкл"}
              selected={v.power}
              icon="power-off"
              onClick={
                () => act('command', { cmd: 'power', val: (v.power === 1 ? 0 : 1), id_tag: v.id_tag })
              } />
            <Button
              content={v.direction === "release" ? "Наполнение" : "Откачка"}
              icon={v.direction === "release" ? "sign-out-alt" : "sign-in-alt"}
              onClick={
                () => act('command', { cmd: 'direction', val: (v.direction === "release" ? 0 : 1), id_tag: v.id_tag })
              } />
          </LabeledList.Item>
          <LabeledList.Item label="Проверки давления">
            <Button
              content="Внешнее"
              selected={v.checks === 1}
              onClick={
                () => act('command', { cmd: 'checks', val: 1, id_tag: v.id_tag })
              } />
            <Button
              content="Внутреннее"
              selected={v.checks === 2}
              onClick={
                () => act('command', { cmd: 'checks', val: 2, id_tag: v.id_tag })
              } />
          </LabeledList.Item>
          <LabeledList.Item label="Целевое внешнее давление">
            <AnimatedNumber value={v.external} /> кПа&nbsp;
            <Button
              content="Задать"
              icon="cog"
              onClick={
                () => act('command', { cmd: 'set_external_pressure', id_tag: v.id_tag })
              } />
            <Button
              content="Сбросить"
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
          <LabeledList.Item label="Статус">
            <Button
              content={s.power ? "Вкл" : "Выкл"}
              selected={s.power}
              icon="power-off"
              onClick={
                () => act('command', { cmd: 'power', val: (s.power === 1 ? 0 : 1), id_tag: s.id_tag })
              } />
            <Button
              content={s.scrubbing === 0 ? "Откачка" : "Вытяжка"}
              icon={s.scrubbing === 0 ? "sign-in-alt" : "filter"}
              onClick={
                () => act('command', { cmd: 'scrubbing', val: (s.scrubbing === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
          </LabeledList.Item>
          <LabeledList.Item label="Диапазон">
            <Button
              content={s.widenet ? "Расширенный" : "Нормальный"}
              selected={s.widenet}
              icon="expand-arrows-alt"
              onClick={
                () => act('command', { cmd: 'widenet', val: (s.widenet === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
          </LabeledList.Item>
          <LabeledList.Item label="Фильтровать">
            <Button
              content="Двуокись углерода"
              selected={s.filter_co2}
              onClick={
                () => act('command', { cmd: 'co2_scrub', val: (s.filter_co2 === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
            <Button
              content="Плазма"
              selected={s.filter_toxins}
              onClick={
                () => act('command', { cmd: 'tox_scrub', val: (s.filter_toxins === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
            <Button
              content="Закись азота"
              selected={s.filter_n2o}
              onClick={
                () => act('command', { cmd: 'n2o_scrub', val: (s.filter_n2o === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
            <Button
              content="Кислород"
              selected={s.filter_o2}
              onClick={
                () => act('command', { cmd: 'o2_scrub', val: (s.filter_o2 === 0 ? 1 : 0), id_tag: s.id_tag })
              } />
            <Button
              content="Азот"
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
      <Section title="Режим системы">
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
      <Section title="Предустановки системы">
        <Box italic>
          После смены предустановки система автоматически начнёт цикл удаления загрязнений.
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
    <Section title="Пороги активации тревог">
      <Table>
        <Table.Row header>
          <Table.Cell width="20%">
            Значение
          </Table.Cell>
          <Table.Cell color="red" width="20%">
            Опасность,<br />если ниже
          </Table.Cell>
          <Table.Cell color="orange" width="20%">
            Угроза,<br />если ниже
          </Table.Cell>
          <Table.Cell color="orange" width="20%">
            Угроза,<br />если выше
          </Table.Cell>
          <Table.Cell color="red" width="20%">
            Опасность,<br />если выше
          </Table.Cell>
        </Table.Row>
        {thresholds.map(t => (
          <Table.Row key={t.name}>
            <Table.Cell>
              {t.name}
            </Table.Cell>
            {t.settings.map(s => (
              <Table.Cell key={s.val}>
                <Button content={s.selected === -1 ? "Выкл" : s.selected} onClick={
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
