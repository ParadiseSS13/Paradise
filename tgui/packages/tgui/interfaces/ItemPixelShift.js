import { useBackend } from "../backend";
import { Button, Section, NumberInput, LabeledList, Grid } from "../components";
import { Window } from "../layouts";

export const ItemPixelShift = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    pixel_x,
    pixel_y,
    max_shift_x,
    max_shift_y,
    random_drop_on,
  } = data;

  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="X-coordinates">
              <Button
                icon="arrow-left"
                title="Shifts item leftwards."
                disabled={pixel_x === max_shift_x}
                onClick={() => act('shift_left')} />
              <NumberInput
                animated
                lineHeight={1.7}
                width="75px"
                unit="pixels"
                stepPixelSize={6}
                value={pixel_x}
                minValue={-max_shift_x}
                maxValue={max_shift_x}
                onChange={(e, value) => act('custom_x', {
                  pixel_x: value,
                })}
              />
              <Button
                icon="arrow-right"
                title="Shifts item rightwards."
                disabled={pixel_x === -max_shift_x}
                onClick={() => act('shift_right')} />
            </LabeledList.Item>
            <LabeledList.Item label="Y-coordinates">
              <Button
                icon="arrow-up"
                title="Shifts item upwards."
                disabled={pixel_y === max_shift_y}
                onClick={() => act('shift_up')} />
              <NumberInput
                animated
                lineHeight={1.7}
                width="75px"
                unit="pixels"
                stepPixelSize={6}
                value={pixel_y}
                minValue={-max_shift_y}
                maxValue={max_shift_y}
                onChange={(e, value) => act('custom_y', {
                  pixel_y: value,
                })}
              />
              <Button
                icon="arrow-down"
                title="Shifts item downwards."
                disabled={pixel_y === -max_shift_y}
                onClick={() => act('shift_down')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section>
          <Grid>
            <Grid.Column>
              <Button
                fluid
                color="brown"
                icon="arrow-up"
                content="Move to Top"
                title="Tries to place an item on top of the others."
                onClick={() => act('move_to_top')} />
            </Grid.Column>
            <Grid.Column>
              <Button
                fluid
                color={random_drop_on ? "good" : "bad"}
                icon="power-off"
                content={random_drop_on ? "Shift Enabled" : "Shift Disabled"}
                title="Enables/Disables item pixel randomization on any drops."
                onClick={() => act('toggle')} />
            </Grid.Column>
          </Grid>
        </Section>
      </Window.Content>
    </Window>
  );
};
