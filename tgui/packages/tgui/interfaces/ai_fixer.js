import { useBackend } from "../backend";
import { Button, ProgressBar, Box, LabeledList } from "../components";
import { Window } from "../layouts";

export const AIFixer = (props, context) => {
  const { act, data } = useBackend(context);
  const laws = data.laws || [];
  if (data.occupant == null) {
    return (
      <Window>
        <Window.Content>
          <Box>
            <h3>No artificial intelligence detected.</h3>
          </Box>
        </Window.Content>
      </Window>
    );
  } else {
    let workingAI = null;
    if (data.stat == 2 || data.stat == null) {
      workingAI = false;
    } else { workingAI = true; }

    let integrityColor = null;
    if (data.integrity >= 75) {integrityColor = 'green';}
    else if (data.integrity >= 25) {integrityColor = 'yellow';}
    else {integrityColor = 'red';}

    return (
      <Window>
        <Window.Content>
          <Box bold>
            <h3>Stored AI: {data.occupant}</h3>
          </Box>

          <Box lineHeight={2}>
            <h3>Information</h3>
          </Box>
          <LabeledList>
            <LabeledList.Item label="Integrity">
              <ProgressBar color={integrityColor} value={data.integrity/100} />
            </LabeledList.Item>
            <LabeledList.Item label="Status"color={workingAI ? "green" : "red"}>
              {workingAI ? "Functional" : "Non-Functional"}
            </LabeledList.Item>
          </LabeledList>

          <Box lineHeight={2}>
            <h3>Laws</h3>
          </Box>
          {/* <LabeledList>
            for (let i = 0; i < lawsList.length; i++) {
              <LabeledList.Item label={{data.laws}[1]} />
            }
          </LabeledList> */}

          {/* {laws.map(law => (
            {law.number} {law.law}
          ))} */}

          <Box>
            <h3>Actions</h3>
          </Box>
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
                icon={data.wireless ? "times" : "check"}
                content={data.wireless ? "Disabled" : "Enabled"}
                color={data.wireless ? "red" : "green"}
                onClick={() => act("wireless")} />
            </LabeledList.Item>
            <LabeledList.Item label="Start Repairs">
              <Button
              icon='wrench'
              disabled={data.integrity >= 100 || data.active}
              content={data.integrity >= 100 ? 'Already Repaired' : 'Repair'}
              onClick={() => act("fix")} />
            </LabeledList.Item>
          </LabeledList>
          <Box color='green' lineHeight={2}>
            {data.active ? "Reconstruction in progress." : ""}
          </Box>
        </Window.Content>
      </Window>
    );
  }
};
