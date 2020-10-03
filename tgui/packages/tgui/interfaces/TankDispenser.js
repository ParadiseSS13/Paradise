import { useBackend } from "../backend";
import { Button, LabeledList, Box, AnimatedNumber, Section } from "../components";
import { Window } from "../layouts";

export const TankDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    o_tanks,
    p_tanks,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Box>
          <Button
            content={"Dispense Oxygen Tank (" + o_tanks + ")"}
            disabled={o_tanks === 0}
            icon="arrow-circle-down"
            onClick={() => act("oxygen")}
          />
        </Box>
        <Box>
          <Button
            content={"Dispense Plasma Tank (" + p_tanks + ")"}
            disabled={p_tanks === 0}
            icon="arrow-circle-down"
            onClick={() => act("plasma")}
          />
        </Box>
      </Window.Content>
    </Window>
  );
};
