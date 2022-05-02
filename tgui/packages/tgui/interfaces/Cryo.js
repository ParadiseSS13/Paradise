import { Fragment } from 'inferno';
import { declensionRu } from 'common/l10n';
import { useBackend } from "../backend";
import { AnimatedNumber, Box, Button, Flex, Icon, LabeledList, ProgressBar, Section } from "../components";
import { Window } from "../layouts";

const damageTypes = [
  {
    label: "Асфиксия",
    type: "oxyLoss",
  },
  {
    label: "Интоксикация",
    type: "toxLoss",
  },
  {
    label: "Раны",
    type: "bruteLoss",
  },
  {
    label: "Ожоги",
    type: "fireLoss",
  },
];

const statNames = [
  ["good", "В сознании"],
  ["average", "Без сознания"],
  ["bad", "ТРУП"],
];

export const Cryo = (props, context) => {
  return (
    <Window>
      <Window.Content className="Layout__content--flexColumn">
        <CryoContent />
      </Window.Content>
    </Window>
  );
};

const CryoContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    isOperating,
    hasOccupant,
    occupant = [],
    cellTemperature,
    cellTemperatureStatus,
    isBeakerLoaded,
    auto_eject_healthy,
    auto_eject_dead,
  } = data;
  return (
    <Fragment>
      <Section
        title="Пациент"
        flexGrow="1"
        buttons={(
          <Button
            icon="user-slash"
            onClick={() => act('ejectOccupant')}
            disabled={!hasOccupant}>
            Извлечь
          </Button>
        )}>
        {hasOccupant ? (
          <LabeledList>
            <LabeledList.Item label="Пациент">
              {occupant.name || "Имя неизвестно"}
            </LabeledList.Item>
            <LabeledList.Item label="Здоровье">
              <ProgressBar
                min={occupant.health}
                max={occupant.maxHealth}
                value={occupant.health / occupant.maxHealth}
                color={occupant.health > 0 ? 'good' : 'average'}>
                <AnimatedNumber
                  value={Math.round(occupant.health)} />
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item
              label="Статус"
              color={statNames[occupant.stat][0]}>
              {statNames[occupant.stat][1]}
            </LabeledList.Item>
            <LabeledList.Item label="Температура">
              <AnimatedNumber value={Math.round(occupant.bodyTemperature)} /> K
            </LabeledList.Item>
            <LabeledList.Divider />
            {(damageTypes.map(damageType => (
              <LabeledList.Item
                key={damageType.id}
                label={damageType.label}>
                <ProgressBar
                  value={occupant[damageType.type]/100}
                  ranges={{ bad: [0.01, Infinity] }}>
                  <AnimatedNumber
                    value={Math.round(occupant[damageType.type])} />
                </ProgressBar>
              </LabeledList.Item>
            )))}
          </LabeledList>
        ) : (
          <Flex height="100%" textAlign="center">
            <Flex.Item grow="1" align="center" color="label">
              <Icon
                name="user-slash"
                mb="0.5rem"
                size="5"
              /><br />
              Пациент не обнаружен.
            </Flex.Item>
          </Flex>
        )}
      </Section>
      <Section
        title="Криокапсула"
        buttons={(
          <Button
            icon="eject"
            onClick={() => act('ejectBeaker')}
            disabled={!isBeakerLoaded}>
            Извлечь ёмкость
          </Button>
        )}>
        <LabeledList>
          <LabeledList.Item label="Питание">
            <Button
              icon="power-off"
              onClick={() => act(isOperating ? 'switchOff' : 'switchOn')}
              selected={isOperating}>
              {isOperating ? "Вкл" : "Выкл"}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Температура" color={cellTemperatureStatus}>
            <AnimatedNumber value={cellTemperature} /> K
          </LabeledList.Item>
          <LabeledList.Item label="Ёмкость">
            <CryoBeaker />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Автоизвлечение здоровых пациентов">
            <Button
              icon={auto_eject_healthy ? "toggle-on" : "toggle-off"}
              selected={auto_eject_healthy}
              onClick={() => act(auto_eject_healthy
                ? 'auto_eject_healthy_off'
                : 'auto_eject_healthy_on'
              )}>
              {auto_eject_healthy ? "Вкл" : "Выкл"}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Автоизвлечение мёртвых пациентов">
            <Button
              icon={auto_eject_dead ? "toggle-on" : "toggle-off"}
              selected={auto_eject_dead}
              onClick={() => act(auto_eject_dead
                ? 'auto_eject_dead_off'
                : 'auto_eject_dead_on'
              )}>
              {auto_eject_dead ? "Вкл" : "Выкл"}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};

const CryoBeaker = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    isBeakerLoaded,
    beakerLabel,
    beakerVolume,
  } = data;
  if (isBeakerLoaded) {
    return (
      <Fragment>
        {beakerLabel
          ? `«${beakerLabel}»`
          : (
            <Box color="average">
              Ёмкость не подписана
            </Box>
          )}
        <Box color={!beakerVolume && "bad"}>
          {beakerVolume ? (
            <AnimatedNumber
              value={beakerVolume}
              format={v => {
                const num = Math.round(v);
                const leftText = declensionRu(num, 'Осталась', 'Остались', 'Осталось');
                const unitText = declensionRu(num, 'единица', 'единицы', 'единиц');
                return `${leftText} ${num} ${unitText}`;
              }}
            />
          ) : "Ёмкость пуста"}
        </Box>
      </Fragment>
    );
  } else {
    return (
      <Box color="average">
        Ёмкость не установлена
      </Box>
    );
  }
};
