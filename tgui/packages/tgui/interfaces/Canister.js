import { toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Dropdown, Icon, Knob, LabeledControls, LabeledList, Section, Tooltip } from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';

export const Canister = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    portConnected,
    tankPressure,
    releasePressure,
    defaultReleasePressure,
    minReleasePressure,
    maxReleasePressure,
    valveOpen,
    name,
    canLabel,
    colorContainer,
    possibleDecals,
    primColor,
    secColor,
    terColor,
    quartColor,
    hasHoldingTank,
    holdingTank,
  } = data;

  let array_prim = [];
  let array_sec = [];
  let array_ter = [];
  let array_quart = [];
  let i = 0;

  for (i = 0; i < colorContainer.prim.options.length; i++) {
    array_prim.push(colorContainer.prim.options[i]["name"]);
  }

  for (i = 0; i < colorContainer.sec.options.length; i++) {
    array_sec.push(colorContainer.sec.options[i]["name"]);
  }
  for (i = 0; i < colorContainer.ter.options.length; i++) {
    array_ter.push(colorContainer.ter.options[i]["name"]);
  }

  for (i = 0; i < colorContainer.quart.options.length; i++) {
    array_quart.push(colorContainer.quart.options[i]["name"]);
  }

  return (
    <Window
      width={300}
      height={232}>
      <Window.Content>
        <Section
          title={name}
          buttons={(
            <Button
              icon="pencil-alt"
              content="Relabel"
              disabled={!canLabel}
              onClick={() => act('relabel')} />
          )}>
          <LabeledControls>
            <LabeledControls.Item
              minWidth="66px"
              label="Pressure">
              <AnimatedNumber
                value={tankPressure}
                format={value => {
                  if (value < 10000) {
                    return toFixed(value) + ' kPa';
                  }
                  return formatSiUnit(value * 1000, 1, 'Pa');
                }} />
            </LabeledControls.Item>
            <LabeledControls.Item label="Regulator">
              <Box
                position="relative"
                left="-8px">
                <Knob
                  size={1.25}
                  color={!!valveOpen && 'yellow'}
                  value={releasePressure}
                  unit="kPa"
                  minValue={minReleasePressure}
                  maxValue={maxReleasePressure}
                  step={5}
                  stepPixelSize={1}
                  onDrag={(e, value) => act('pressure', {
                    pressure: value,
                  })} />
                <Button
                  fluid
                  position="absolute"
                  top="-2px"
                  right="-20px"
                  color="transparent"
                  icon="fast-forward"
                  onClick={() => act('pressure', {
                    pressure: maxReleasePressure,
                  })} />
                <Button
                  fluid
                  position="absolute"
                  top="16px"
                  right="-20px"
                  color="transparent"
                  icon="undo"
                  onClick={() => act('pressure', {
                    pressure: defaultReleasePressure,
                  })} />
              </Box>
            </LabeledControls.Item>
            <LabeledControls.Item label="Valve">
              <Button
                my={0.5}
                width="50px"
                lineHeight={2}
                fontSize="11px"
                color={valveOpen
                  ? (hasHoldingTank ? 'caution' : 'danger')
                  : null}
                content={valveOpen ? 'Open' : 'Closed'}
                onClick={() => act('valve')} />
            </LabeledControls.Item>
            <LabeledControls.Item
              mr={1}
              label="Port">
              <Box position="relative">
                <Icon
                  size={1.25}
                  name={portConnected ? 'plug' : 'times'}
                  color={portConnected ? 'good' : 'bad'} />
                <Tooltip
                  content={portConnected
                    ? 'Connected'
                    : 'Disconnected'}
                  position="top" />
              </Box>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Section
          title="Holding Tank"
          buttons={!!hasHoldingTank && (
            <Button
              icon="eject"
              color={valveOpen && 'danger'}
              content="Eject"
              onClick={() => act('eject')} />
          )}>
          {!!hasHoldingTank && (
            <LabeledList>
              <LabeledList.Item label="Label">
                {holdingTank.name}
              </LabeledList.Item>
              <LabeledList.Item label="Pressure">
                <AnimatedNumber value={holdingTank.tankPressure} /> kPa
              </LabeledList.Item>
            </LabeledList>
          )}
          {!hasHoldingTank && (
            <Box color="average">
              No Holding Tank
            </Box>
          )}
        </Section>

        <Section title="Paint">
          <LabeledControls>
            <LabeledControls.Item
              minWidth="100px"
              label={colorContainer.prim.name}>
              <Dropdown
                over
                selected=""
                disabled={!canLabel}
                options={array_prim}
                width="100px"
                onSelected={value => act('recolor',
                  { nc: array_prim.indexOf(value),
                    ctype: "prim" })} />
            </LabeledControls.Item>
            <LabeledControls.Item
              minWidth="100px"
              label={colorContainer.sec.name}>
              <Dropdown
                over
                selected=""
                disabled={!canLabel}
                options={array_sec}
                width="100px"
                onSelected={value => act('recolor',
                  { nc: array_sec.indexOf(value),
                    ctype: "sec" })} />
            </LabeledControls.Item>
            <LabeledControls.Item
              minWidth="100px"
              label={colorContainer.ter.name}>
              <Dropdown
                over
                selected=""
                disabled={!canLabel}
                options={array_ter}
                width="100px"
                onSelected={value => act('recolor',
                  { nc: array_ter.indexOf(value),
                    ctype: "ter" })} />
            </LabeledControls.Item>
            <LabeledControls.Item
              minWidth="100px"
              label={colorContainer.quart.name}>
              <Dropdown
                over
                selected=""
                disabled={!canLabel}
                options={array_quart}
                width="100px"
                onSelected={value => act('recolor',
                  { nc: array_quart.indexOf(value),
                    ctype: "quart" })} />
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};
