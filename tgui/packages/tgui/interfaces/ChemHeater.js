import { round, toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Window } from "../layouts";
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section } from "../components";
import { BeakerContents } from '../interfaces/common/BeakerContents';

export const ChemHeater = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hasPower,
    targetTemp,
    isActive,
    isBeakerLoaded,
    currentTemp,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents = [],
  } = data;
  return (
    <Window resizable>
      <Window.Content className="Layout__content--flexColumn">
        <Section
          title="Settings"
          flexBasis="content"
          buttons={(
            <Button
              content={(hasPower && isActive) ? "On" : "Off"}
              icon="power-off"
              selected={hasPower && isActive}
              disabled={!isBeakerLoaded || !hasPower}
              onClick={() => act("toggle_on")}
            />
          )}>
          <LabeledList>
            <LabeledList.Item label="Target">
              <NumberInput
                width="65px"
                unit="K"
                step={10}
                stepPixelSize={3}
                value={round(targetTemp)}
                minValue={0}
                maxValue={1000}
                onDrag={(e, value) => act('adjust_temperature', {
                  target: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Reading">
              <Box width="60px" textAlign="right">
                {isBeakerLoaded && (
                  <AnimatedNumber
                    value={currentTemp}
                    format={value => toFixed(value) + " K"} />
                ) || '—'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
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
      </Window.Content>
    </Window>
  );
};
