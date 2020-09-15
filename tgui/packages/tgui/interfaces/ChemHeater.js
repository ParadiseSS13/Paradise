import { round, toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section } from "../components";
import { BeakerContents } from '../interfaces/common/BeakerContents';
import { Window } from "../layouts";

export const ChemHeater = (_props, _context) => {
  return (
    <Window resizable>
      <Window.Content className="Layout__content--flexColumn">
        <ChemHeaterSettings />
        <ChemHeaterBeaker />
      </Window.Content>
    </Window>
  );
};

const ChemHeaterSettings = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    targetTemp,
    targetTempReached,
    autoEject,
    isActive,
    currentTemp,
    isBeakerLoaded,
  } = data;
  return (
    <Section
      title="Settings"
      flexBasis="content"
      buttons={(
        <Fragment>
          <Button
            content="Auto-eject"
            icon={autoEject ? "toggle-on" : "toggle-off"}
            selected={autoEject}
            onClick={() => act("toggle_autoeject")} />
          <Button
            content={isActive ? "On" : "Off"}
            icon="power-off"
            selected={isActive}
            disabled={!isBeakerLoaded}
            onClick={() => act("toggle_on")} />
        </Fragment>
      )}>
      <LabeledList>
        <LabeledList.Item label="Target">
          <NumberInput
            width="65px"
            unit="K"
            step={10}
            stepPixelSize={3}
            value={round(targetTemp, 0)}
            minValue={0}
            maxValue={1000}
            onDrag={(e, value) => act('adjust_temperature', {
              target: value,
            })}
          />
        </LabeledList.Item>
        <LabeledList.Item
          label="Reading"
          color={targetTempReached ? "good" : "average"}>
          {isBeakerLoaded && (
            <AnimatedNumber
              value={currentTemp}
              format={value => toFixed(value) + " K"} />
          ) || '—'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ChemHeaterBeaker = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    isBeakerLoaded,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents,
  } = data;
  return (
    <Section
      title="Beaker"
      flexGrow="1"
      buttons={!!isBeakerLoaded && (
        <Box>
          <Box inline color="label" mr={2}>
            {beakerCurrentVolume} / {beakerMaxVolume} units
          </Box>
          <Button
            icon="eject"
            content="Eject"
            onClick={() => act('eject_beaker')} />
        </Box>
      )}>
      <BeakerContents
        beakerLoaded={isBeakerLoaded}
        beakerContents={beakerContents}
      />
    </Section>
  );
};
