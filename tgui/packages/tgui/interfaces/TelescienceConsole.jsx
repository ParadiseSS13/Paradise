import { useState } from 'react';
import { Box, Button, Icon, LabeledList, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const TelescienceConsole = (properties) => {
  const { act, data } = useBackend();
  const {
    last_msg,
    linked_pad,
    held_gps,
    lastdata,
    power_levels,
    current_max_power,
    current_power,
    current_bearing,
    current_elevation,
    current_sector,
    working,
    max_z,
  } = data;
  const [dummyRot, setDummyRot] = useState(current_bearing);

  return (
    <Window width={400} height={500}>
      <Window.Content>
        <Section title="Status">
          <>
            {last_msg}
            {!(lastdata.length > 0) || (
              <ul>
                {lastdata.map((x) => (
                  <li key={x}>{x}</li>
                ))}
              </ul>
            )}
          </>
        </Section>
        <Section title="Telepad Status">
          {linked_pad === 1 ? (
            <LabeledList>
              <LabeledList.Item label="Current Bearing">
                <Box inline position="relative">
                  <NumberInput
                    unit={'°'}
                    width={6.1}
                    lineHeight={1.5}
                    step={0.1}
                    minValue={0}
                    maxValue={360}
                    disabled={working}
                    value={current_bearing}
                    onChange={(value) => {
                      setDummyRot(value);
                      act('setbear', { bear: value });
                    }}
                  />
                  <Icon ml={1} size={1} name="arrow-up" rotation={dummyRot} />
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Current Elevation">
                <NumberInput
                  width={6.1}
                  lineHeight={1.5}
                  step={0.1}
                  minValue={0}
                  maxValue={100}
                  disabled={working}
                  value={current_elevation}
                  onChange={(value) => act('setelev', { elev: value })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Power Level">
                {power_levels.map((p, idx) => (
                  <Button
                    key={p}
                    content={p}
                    selected={current_power === p}
                    disabled={idx >= current_max_power - 1 || working} // -1 here, its a BYONDism
                    onClick={() => act('setpwr', { pwr: idx + 1 })}
                  />
                ))}
              </LabeledList.Item>
              <LabeledList.Item label="Target Sector">
                <NumberInput
                  width={6.1}
                  lineHeight={1.5}
                  step={1}
                  minValue={2}
                  maxValue={max_z}
                  value={current_sector}
                  disabled={working}
                  onChange={(value) => act('setz', { newz: value })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Telepad Actions">
                <Button content="Send" disabled={working} onClick={() => act('pad_send')} />
                <Button content="Receive" disabled={working} onClick={() => act('pad_receive')} />
              </LabeledList.Item>
              <LabeledList.Item label="Crystal Maintenance">
                <Button content="Recalibrate Crystals" disabled={working} onClick={() => act('recal_crystals')} />
                <Button content="Eject Crystals" disabled={working} onClick={() => act('eject_crystals')} />
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <>No pad linked to console. Please use a multitool to link a pad.</>
          )}
        </Section>
        <Section title="GPS Actions">
          {held_gps === 1 ? (
            <>
              <Button disabled={held_gps === 0 || working} content="Eject GPS" onClick={() => act('eject_gps')} />
              <Button
                disabled={held_gps === 0 || working}
                content="Store Coordinates"
                onClick={() => act('store_to_gps')}
              />
            </>
          ) : (
            <>Please insert a GPS to store coordinates to it.</>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
