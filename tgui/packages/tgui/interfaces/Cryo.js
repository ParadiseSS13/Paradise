import { round, toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Window } from "../layouts";
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section } from "../components";

const damageTypes = [
  {
    label: "Respiratory",
    type: "oxyLoss",
  },
  {
    label: "Toxin",
    type: "toxLoss",
  },
  {
    label: "Brute",
    type: "bruteLoss",
  },
  {
    label: "Burn",
    type: "fireLoss",
  },
];

const statNames = [
  ["good", "Conscious"],
  ["average", "Unconscious"],
  ["bad", "DEAD"],
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
        title="Occupant"
        flexGrow="1"
        buttons={(
          <Button
            icon="user-slash"
            onClick={() => act('ejectOccupant')}
            disabled={!hasOccupant}>
            Eject
          </Button>
        )}>
        <LabeledList>
          <LabeledList.Item label="Occupant">
            {occupant.name || 'No Occupant'}
          </LabeledList.Item>
          {!!hasOccupant && (
            <Fragment>
              <LabeledList.Item
                label="State"
                color={statNames[occupant.stat][0]}>
                {statNames[occupant.stat][1]}
              </LabeledList.Item>
              <LabeledList.Item label="Temperature">
                <AnimatedNumber
                  value={Math.round(occupant.bodyTemperature)} />
                {' K'}
              </LabeledList.Item>
              <LabeledList.Item label="Health">
                <ProgressBar
                  value={occupant.health / occupant.maxHealth}
                  color={occupant.health > 0 ? 'good' : 'average'}>
                  <AnimatedNumber
                    value={Math.round(occupant.health)} />
                </ProgressBar>
              </LabeledList.Item>
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
            </Fragment>
          )}
        </LabeledList>
      </Section>
      <Section
        title="Cell"
        buttons={(
          <Button
            icon="eject"
            onClick={() => act('ejectBeaker')}
            disabled={!isBeakerLoaded}>
            Eject Beaker
          </Button>
        )}>
        <LabeledList>
          <LabeledList.Item label="Power">
            <Button
              icon="power-off"
              onClick={() => act(isOperating ? 'switchOff' : 'switchOn')}
              selected={isOperating}>
              {isOperating ? "On" : "Off"}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Temperature" color={cellTemperatureStatus}>
            <AnimatedNumber value={cellTemperature} /> K
          </LabeledList.Item>
          <LabeledList.Item label="Beaker">
            <CryoBeaker />
          </LabeledList.Item>
          <LabeledList.Item label="Auto-eject healthy occupants">
            <Button
              icon={auto_eject_healthy ? "toggle-on" : "toggle-off"}
              selected={auto_eject_healthy}
              mt="1rem"
              onClick={() => act(auto_eject_healthy
                ? 'auto_eject_healthy_off'
                : 'auto_eject_healthy_on'
              )}>
              {auto_eject_healthy ? "On" : "Off"}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Auto-eject dead occupants">
            <Button
              icon={auto_eject_dead ? "toggle-on" : "toggle-off"}
              selected={auto_eject_dead}
              onClick={() => act(auto_eject_dead
                ? 'auto_eject_dead_off'
                : 'auto_eject_dead_on'
              )}>
              {auto_eject_dead ? "On" : "Off"}
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
          ? beakerLabel
          : (
            <Box color="average">
              No label
            </Box>
          )}
        <Box color={!beakerVolume && "bad"}>
          {beakerVolume ? (
            <AnimatedNumber
              value={beakerVolume}
              format={v => Math.round(v) + " units remaining"}
            />
          ) : "Beaker is empty"}
        </Box>
      </Fragment>
    );
  } else {
    return (
      <Box color="average">
        No beaker loaded
      </Box>
    );
  }
};
