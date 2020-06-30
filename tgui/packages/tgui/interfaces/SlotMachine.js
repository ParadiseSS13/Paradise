import { useBackend } from "../backend";
import { Button, LabeledList, Box, AnimatedNumber } from "../components";
import { Window } from "../layouts";

export const SlotMachine = (props, context) => {
  const { act, data } = useBackend(context);
  if (data.money === null) {
    return (
      <Window>
        <Window.Content>
          <Box m={1}>
            <Box>
              Could not scan your card or could not find account!
            </Box>
            <Box>
              Please wear or hold your ID and try again.
            </Box>
          </Box>
        </Window.Content>
      </Window>
    );
  } else {
    let playerText;
    if (data.plays === 1) {
      playerText = data.plays + " player has tried their luck today!";
    } else {
      playerText = data.plays + " players have tried their luck today!";
    }
    return (
      <Window>
        <Window.Content>
          <Box m={1}>
            <Box lineHeight={2}>
              {playerText}
            </Box>
            <LabeledList>
              <LabeledList.Item label="Credits Remaining">
                <AnimatedNumber
                  value={data.money}
                />
              </LabeledList.Item>
              <LabeledList.Item label="10 credits to spin">
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
          </Box>
        </Window.Content>
      </Window>
    );
  }
};
