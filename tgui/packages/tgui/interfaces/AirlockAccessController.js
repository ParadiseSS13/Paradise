import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const AirlockAccessController = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    exterior_status,
    interior_status,
    processing,
  } = data;
  let exteriorbutton;
  let interiorbutton;
  // If exterior is open, then it can be locked, if closed, it can be cycled to. Vice versa for interior

  if (data.exterior_status.state === "open") {
    exteriorbutton = (
      <Button
        content={"Lock Exterior Door"}
        icon={"exclamation-triangle"}
        disabled={processing}
        onClick={() => act("force_ext")} />
    );
  } else {
    exteriorbutton = (
      <Button
        content={"Cycle to Exterior"}
        icon={"arrow-circle-left"}
        disabled={processing}
        onClick={() => act("cycle_ext_door")} />
    );
  }
  if (data.interior_status.state === "open") {
    interiorbutton = (
      <Button
        content={"Lock Interior Door"}
        icon={"exclamation-triangle"}
        disabled={processing}
        color={interior_status === "open" ? "red" : processing ? "yellow": null}
        onClick={() => act("force_int")} />
    );
  } else {
    interiorbutton = (
      <Button
        content={"Cycle to Interior"}
        icon={"arrow-circle-right"}
        disabled={processing}
        onClick={() => act("cycle_int_door")} />
    );
  }
  return (
    <Window>
      <Window.Content>
        <Section title="Information">
          <LabeledList>
            <LabeledList.Item label="External Door Status">
              {exterior_status.state === "closed" ? "Locked" : "Open"}
            </LabeledList.Item>
            <LabeledList.Item label="Internal Door Status">
              {interior_status.state === "closed" ? "Locked" : "Open"}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Actions">
          <Box>
            {exteriorbutton}
          </Box>
          <Box>
            {interiorbutton}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
