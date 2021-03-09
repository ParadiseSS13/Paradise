import { useBackend } from "../backend";
import { Button, ProgressBar, LabeledList, Box, Section } from "../components";
import { Window } from "../layouts";

export const AICard = (props, context) => {
  const { act, data } = useBackend(context);
  if (data.has_ai === 0) {
    return (
      <Window>
        <Window.Content>
          <Section title="Stored AI">
            <Box>
              <h3>No AI detected.</h3>
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {

    let integrityColor = null; // Handles changing color of the integrity bar
    if (data.integrity >= 75) { integrityColor = 'green'; }
    else if (data.integrity >= 25) { integrityColor = 'yellow'; }
    else { integrityColor = 'red'; }

    return (
      <Window scrollable>
        <Window.Content>
          <Section title="Stored AI">
            <Box bold display="inline-block">
              <h3>{data.name}</h3>
            </Box>
            <Box>
              <LabeledList>
                <LabeledList.Item label="Integrity">
                  <ProgressBar
                    color={integrityColor}
                    value={data.integrity/100} />
                </LabeledList.Item>
              </LabeledList>
            </Box>
            <Box color="red">
              <h2>{data.flushing === 1 ? "Wipe of AI in progress..." : ""}</h2>
            </Box>
          </Section>

          <Section title="Laws">
            {!!data.has_laws && (
              <Box>
                {data.laws.map((value, key) => (
                  <Box key={key} display="inline-block">
                    {value}
                  </Box>
                ))}
              </Box>
            ) || ( // Else, no laws.
              <Box color="red">
                <h3>No laws detected.</h3>
              </Box>
            )}
          </Section>

          <Section title="Actions">
            <LabeledList>
              <LabeledList.Item label="Wireless Activity">
                <Button
                  icon={data.wireless ? "check" : "times"}
                  content={data.wireless ? "Enabled" : "Disabled"}
                  color={data.wireless ? "green" : "red"}
                  onClick={() => act("wireless")} />
              </LabeledList.Item>
              <LabeledList.Item label="Subspace Transceiver">
                <Button
                  icon={data.radio ? "check" : "times"}
                  content={data.radio ? "Enabled" : "Disabled"}
                  color={data.radio ? "green" : "red"}
                  onClick={() => act("radio")} />
              </LabeledList.Item>
              <LabeledList.Item label="Wipe">
                <Button.Confirm
                  icon="trash-alt"
                  confirmIcon="trash-alt"
                  disabled={data.flushing || data.integrity === 0}
                  confirmColor="red"
                  content="Wipe AI"
                  onClick={() => act("wipe")} />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Window.Content>
      </Window>
    );
  }
};
