import {
  AnimatedNumber,
  Box,
  Button,
  Dropdown,
  Icon,
  Knob,
  LabeledControls,
  LabeledList,
  Section,
  Tooltip,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Canister = (props) => {
  const { act, data } = useBackend();
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
    color_index,
    hasHoldingTank,
    holdingTank,
  } = data;

  let preset_prim = '';
  if (color_index['prim']) {
    preset_prim = colorContainer.prim.options[color_index['prim']]['name'];
  }
  let preset_sec = '';
  if (color_index['sec']) {
    preset_sec = colorContainer.sec.options[color_index['sec']]['name'];
  }
  let preset_ter = '';
  if (color_index['ter']) {
    preset_ter = colorContainer.ter.options[color_index['ter']]['name'];
  }
  let preset_quart = '';
  if (color_index['quart']) {
    preset_quart = colorContainer.quart.options[color_index['quart']]['name'];
  }

  let array_prim = [];
  let array_sec = [];
  let array_ter = [];
  let array_quart = [];
  let i = 0;

  for (i = 0; i < colorContainer.prim.options.length; i++) {
    array_prim.push(colorContainer.prim.options[i]['name']);
  }
  for (i = 0; i < colorContainer.sec.options.length; i++) {
    array_sec.push(colorContainer.sec.options[i]['name']);
  }
  for (i = 0; i < colorContainer.ter.options.length; i++) {
    array_ter.push(colorContainer.ter.options[i]['name']);
  }
  for (i = 0; i < colorContainer.quart.options.length; i++) {
    array_quart.push(colorContainer.quart.options[i]['name']);
  }
  let paintSection = '';
  if (canLabel) {
    paintSection = (
      <Section title="Paint">
        <LabeledControls>
          <LabeledControls.Item minWidth="110px" label={colorContainer.prim.name}>
            <Dropdown
              over
              selected={preset_prim}
              disabled={!canLabel}
              options={array_prim}
              width="110px"
              onSelected={(value) => act('recolor', { nc: array_prim.indexOf(value), ctype: 'prim' })}
            />
          </LabeledControls.Item>
          <LabeledControls.Item minWidth="110px" label={colorContainer.sec.name}>
            <Dropdown
              over
              selected={preset_sec}
              disabled={!canLabel}
              options={array_sec}
              width="110px"
              onSelected={(value) => act('recolor', { nc: array_sec.indexOf(value), ctype: 'sec' })}
            />
          </LabeledControls.Item>
          <LabeledControls.Item minWidth="110px" label={colorContainer.ter.name}>
            <Dropdown
              over
              selected={preset_ter}
              disabled={!canLabel}
              options={array_ter}
              width="110px"
              onSelected={(value) => act('recolor', { nc: array_ter.indexOf(value), ctype: 'ter' })}
            />
          </LabeledControls.Item>
          <LabeledControls.Item minWidth="110px" label={colorContainer.quart.name}>
            <Dropdown
              over
              selected={preset_quart}
              disabled={!canLabel}
              options={array_quart}
              width="110px"
              onSelected={(value) =>
                act('recolor', {
                  nc: array_quart.indexOf(value),
                  ctype: 'quart',
                })
              }
            />
          </LabeledControls.Item>
        </LabeledControls>
      </Section>
    );
  }

  return (
    <Window width={600} height={canLabel ? 300 : 230}>
      <Window.Content>
        <Section
          title={name}
          buttons={<Button icon="pencil-alt" content="Relabel" disabled={!canLabel} onClick={() => act('relabel')} />}
        >
          <LabeledControls>
            <LabeledControls.Item minWidth="66px" label="Pressure">
              <AnimatedNumber
                value={tankPressure}
                format={(value) => {
                  if (value < 10000) {
                    return toFixed(value) + ' kPa';
                  }
                  return formatSiUnit(value * 1000, 1, 'Pa');
                }}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Regulator">
              <Box position="relative" left="-8px">
                <Knob
                  size={1.25}
                  color={!!valveOpen && 'yellow'}
                  value={releasePressure}
                  unit="kPa"
                  minValue={minReleasePressure}
                  maxValue={maxReleasePressure}
                  step={5}
                  stepPixelSize={1}
                  tickWhileDragging
                  onChange={(e, value) =>
                    act('pressure', {
                      pressure: value,
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="-2px"
                  right="-20px"
                  color="transparent"
                  icon="fast-forward"
                  tooltip="Max Release Pressure"
                  onClick={() =>
                    act('pressure', {
                      pressure: maxReleasePressure,
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="16px"
                  right="-20px"
                  color="transparent"
                  icon="undo"
                  tooltip="Reset Release Pressure"
                  onClick={() =>
                    act('pressure', {
                      pressure: defaultReleasePressure,
                    })
                  }
                />
              </Box>
            </LabeledControls.Item>
            <LabeledControls.Item label="Valve">
              <Button
                my={0.5}
                width="50px"
                lineHeight={2}
                fontSize="11px"
                color={valveOpen ? (hasHoldingTank ? 'caution' : 'danger') : null}
                content={valveOpen ? 'Open' : 'Closed'}
                onClick={() => act('valve')}
              />
            </LabeledControls.Item>
            <LabeledControls.Item mr={1} label="Port">
              <Tooltip content={portConnected ? 'Connected' : 'Disconnected'} position="top">
                <Box position="relative">
                  <Icon size={1.25} name={portConnected ? 'plug' : 'times'} color={portConnected ? 'good' : 'bad'} />
                </Box>
              </Tooltip>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Section
          title="Holding Tank"
          buttons={!!hasHoldingTank && <Button icon="eject" content="Eject" onClick={() => act('eject')} />}
        >
          {!!hasHoldingTank && (
            <LabeledList>
              <LabeledList.Item label="Label">{holdingTank.name}</LabeledList.Item>
              <LabeledList.Item label="Pressure">
                <AnimatedNumber value={holdingTank.tankPressure} /> kPa
              </LabeledList.Item>
            </LabeledList>
          )}
          {!hasHoldingTank && <Box color="average">No Holding Tank</Box>}
        </Section>
        {paintSection}
      </Window.Content>
    </Window>
  );
};
