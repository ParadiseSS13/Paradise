import { useBackend } from "../backend";
import { Button, LabeledList, Section, Box, ProgressBar } from "../components";
import { Window } from "../layouts";

export const DisposalBin = (props, context) => {
  const { act, data } = useBackend(context);
  let stateColor;
  let stateText;
  if (data.mode === 2) {
    stateColor = "good";
    stateText = "Ready";
  } else if (data.mode <= 0) {
    stateColor = "bad";
    stateText = "N/A";
  } else if (data.mode === 1) {
    stateColor = "average";
    stateText = "Pressurizing";
  } else {
    stateColor = "average";
    stateText = "Idle";
  }
  return (
    <Window>
      <Window.Content>
        <Section>
          <Box bold m={1}>
            Status
          </Box>
          <LabeledList>
            <LabeledList.Item label="State" color={stateColor}>
              {stateText}
            </LabeledList.Item>
            <LabeledList.Item
              label="Pressure">
              <ProgressBar
                ranges={{
                  bad: [-Infinity, 0],
                  average: [0, 99],
                  good: [99, Infinity],
                }}
                value={data.pressure}
                minValue={0}
                maxValue={100} />
            </LabeledList.Item>
          </LabeledList>
          <Box bold m={1}>
            Controls
          </Box>
          <LabeledList>
            <LabeledList.Item label="Handle">
              <Button
                icon="toggle-off"
                disabled={data.isAI || data.panel_open}
                content="Disengaged"
                selected={data.flushing ? null : "selected"}
                onClick={() => act("disengageHandle")}
              />
              <Button
                icon="toggle-on"
                disabled={data.isAI || data.panel_open}
                content="Engaged"
                selected={data.flushing ? "selected" : null}
                onClick={() => act("engageHandle")}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <Button
                icon="toggle-off"
                disabled={data.mode === -1}
                content="Off"
                selected={data.mode ? null : "selected"}
                onClick={() => act("pumpOff")}
              />
              <Button
                icon="toggle-on"
                disabled={data.mode === -1}
                content="On"
                selected={data.mode ? "selected" : null}
                onClick={() => act("pumpOn")}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Eject">
              <Button
                icon="sign-out-alt"
                disabled={data.isAI}
                content="Eject Contents"
                onClick={() => act("eject")}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
