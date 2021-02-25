import { useBackend } from "../backend";
import { Button, LabeledList, Box, AnimatedNumber, Section } from "../components";
import { Window } from "../layouts";

export const SlotMachine = (props, context) => {
  const { act, data } = useBackend(context);
  let playerText;
  if (data.plays === 1) {
    playerText = data.plays + " player has tried their luck today!";
  } else {
    playerText = data.plays + " players have tried their luck today!";
  }
  return (
    <Window>
      <Window.Content>
        <Section>
          <Box lineHeight={2}>
            {playerText}
          </Box>
          <LabeledList>
            <LabeledList.Item label="FREE spin">
              <Button
                icon="coins"
                disabled={data.working}
                content={data.working ? "Spinning..." : "Spin"}
                onClick={() => act("spin")} />
            </LabeledList.Item>
          </LabeledList>
          <Box bold lineHeight={2} color={data.resultlvl}>
            {data.result}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
