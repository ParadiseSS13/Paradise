import { useBackend } from "../backend";
import { Button, ProgressBar, Box, LabeledList, Section } from "../components";
import { Window } from "../layouts";

export const AIFixer = (props, context) => {
  const { act, data } = useBackend(context);
  if (data.occupant === null) {
    return (
      <Window>
        <Window.Content>
          <Section title="Stored AI">
            <Box>
              <h3>No artificial intelligence detected.</h3>
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {

    let workingAI = null; // If the AI is dead (stat = 2) or isn't existent
    if (data.stat === 2 || data.stat === null) {
      workingAI = false;
    } else {
      workingAI = true;
    }

    let integrityColor = null; // Handles changing color of the integrity bar
    if (data.integrity >= 75) { integrityColor = 'green'; }
    else if (data.integrity >= 25) { integrityColor = 'yellow'; }
    else { integrityColor = 'red'; }

    let integrityFull = null; // If integrity >= 100, prevents overchar
    if (data.integrity >= 100) { integrityFull = true; }
    else { integrityFull = false; }


    return (
      <Window scrollable>
        <Window.Content>
          <Section title="Stored AI">
            <Box bold>
              <h3>{data.occupant}</h3>
            </Box>
          </Section>

          <Section title="Information">
            <LabeledList>
              <LabeledList.Item label="Integrity">
                <ProgressBar
                  color={integrityColor}
                  value={data.integrity/100} />
              </LabeledList.Item>
              <LabeledList.Item
                label="Status"
                color={workingAI ? "green" : "red"}>
                {workingAI ? "Functional" : "Non-Functional"}
              </LabeledList.Item>
            </LabeledList>
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
                  icon={data.wireless ? "times" : "check"}
                  content={data.wireless ? "Disabled" : "Enabled"}
                  color={data.wireless ? "red" : "green"}
                  onClick={() => act("wireless")} />
              </LabeledList.Item>
              <LabeledList.Item label="Subspace Transceiver">
                <Button
                  icon={data.radio ? "times" : "check"}
                  content={data.radio ? "Disabled" : "Enabled"}
                  color={data.radio ? "red" : "green"}
                  onClick={() => act("radio")} />
              </LabeledList.Item>
              <LabeledList.Item label="Start Repairs">
                <Button
                  icon="wrench"
                  disabled={integrityFull || data.active}
                  content={integrityFull ? 'Already Repaired' : 'Repair'}
                  onClick={() => act("fix")} />
              </LabeledList.Item>
            </LabeledList>
            <Box color="green" lineHeight={2}>
              {data.active ? "Reconstruction in progress." : ""}
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }
};
