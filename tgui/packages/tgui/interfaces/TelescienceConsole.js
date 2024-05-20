import { useBackend, useLocalState } from '../backend';
import {
  Box,
  NumberInput,
  Button,
  Icon,
  LabeledList,
  Section,
} from '../components';
import { Window } from '../layouts';

export const TelescienceConsole = (properties, context) => {
  const { data } = useBackend(context);
  const {
    last_msg,
    linked_pad,
    held_gps,
    lastdata,
    power_levels,
    current_power,
    current_bearing,
    current_elevation,
    current_sector,
  } = data;
  const [dummyRot, setDummyRot] = useLocalState(
    context,
    'dummyrot',
    current_bearing
  );

  return (
    <Window width={400} height={450}>
      <Window.Content>
        <Section title="Status">{last_msg}</Section>
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
                    value={current_bearing}
                    onDrag={(e, value) => setDummyRot(value)}
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
                  value={current_elevation}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Power Level">
                {power_levels.map((p, idx) => (
                  <Button
                    key={p}
                    content={p}
                    selected={current_power === p}
                    disabled={idx >= current_power - 1} // -1 here, its a BYONDism
                  />
                ))}
              </LabeledList.Item>
              <LabeledList.Item label="Target Sector">
                <NumberInput
                  width={6.1}
                  lineHeight={1.5}
                  step={1}
                  minValue={2}
                  maxValue={10}
                  value={current_sector}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Telepad Actions">
                <Button content="Send" />
                <Button content="Receive" />
              </LabeledList.Item>
              <LabeledList.Item label="Crystal Maintenance">
                <Button content="Recalibrate Crystals" />
                <Button content="Eject Crystals" />
              </LabeledList.Item>
              <LabeledList.Item label="Teleportation Info">
                {lastdata.length > 0 ? (
                  lastdata.map((element) => {
                    <p>{element}</p>;
                  })
                ) : (
                  <>Data will be available after pad use</>
                )}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <>No pad linked to console. Please use a multitool to link a pad.</>
          )}
        </Section>
        <Section title="GPS Actions">
          {held_gps === 1 ? (
            <>
              <Button disabled={held_gps === 0} content="Eject GPS" />
              <Button disabled={held_gps === 0} content="Store Coordinates" />
            </>
          ) : (
            <>Please insert a GPS to store coordinates to it.</>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
