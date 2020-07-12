import { round, toFixed } from 'common/math';
import { useBackend } from "../backend";
import { AnimatedNumber, Box, Button, Knob, LabeledList, Section } from "../components";
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
    isActive,
    currentTemp,
    isBeakerLoaded,
  } = data;
  return (
    <Section
      title="Settings"
      flexBasis="content"
      buttons={(
        <Button
          content={isActive ? "On" : "Off"}
          icon="power-off"
          selected={isActive}
          disabled={!isBeakerLoaded}
          onClick={() => act("toggle_on")} />
      )}>
      <LabeledList>
        <LabeledList.Item label="Target">
          <Knob
            minValue="0"
            maxValue="1000"
            value={round(targetTemp, 0)}
            step="5"
            unit="K"
            m="0"
            onChange={(_e, value) => act('adjust_temperature', {
              target: value,
            })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Reading">
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
