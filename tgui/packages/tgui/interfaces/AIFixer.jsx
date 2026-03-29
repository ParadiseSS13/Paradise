import { Box, Button, Icon, LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const AIFixer = (props) => {
  const { act, data } = useBackend();
  if (data.occupant === null) {
    return (
      <Window width={550} height={500}>
        <Window.Content>
          <Section fill title="Stored AI">
            <Stack fill>
              <Stack.Item bold grow textAlign="center" align="center" color="average">
                <Icon.Stack>
                  <Icon name="robot" size={5} color="silver" />
                  <Icon name="slash" size={5} color="red" />
                </Icon.Stack>
                <br />
                <h3>No Artificial Intelligence detected.</h3>
              </Stack.Item>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {
    let workingAI = true; // If the AI is dead (stat = 2) or isn't existent
    if (data.stat === 2 || data.stat === null) {
      workingAI = false;
    }

    let integrityColor = null; // Handles changing color of the integrity bar
    if (data.integrity >= 75) {
      integrityColor = 'green';
    } else if (data.integrity >= 25) {
      integrityColor = 'yellow';
    } else {
      integrityColor = 'red';
    }

    let repairable = true; // Is the AI repairable? (Stat 2 = dead)
    if (data.integrity >= 100 && data.stat !== 2) {
      repairable = false;
    }

    return (
      <Window>
        <Window.Content scrollable>
          <Stack fill vertical>
            <Stack.Item>
              <Section title={data.occupant}>
                <LabeledList>
                  <LabeledList.Item label="Integrity">
                    <ProgressBar color={integrityColor} value={data.integrity / 100} />
                  </LabeledList.Item>
                  <LabeledList.Item label="Status" color={workingAI ? 'green' : 'red'}>
                    {workingAI ? 'Functional' : 'Non-Functional'}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill scrollable title="Laws">
                {(!!data.has_laws && (
                  <Box>
                    {data.laws.map((value, key) => (
                      <Box key={key} inline>
                        {value}
                      </Box>
                    ))}
                  </Box>
                )) || ( // Else, no laws.
                  <Box color="red">
                    <h3>No laws detected.</h3>
                  </Box>
                )}
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Actions">
                <LabeledList>
                  <LabeledList.Item label="Wireless Activity">
                    <Button
                      icon={data.wireless ? 'times' : 'check'}
                      content={data.wireless ? 'Disabled' : 'Enabled'}
                      color={data.wireless ? 'red' : 'green'}
                      onClick={() => act('wireless')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Subspace Transceiver">
                    <Button
                      icon={data.radio ? 'times' : 'check'}
                      content={data.radio ? 'Disabled' : 'Enabled'}
                      color={data.radio ? 'red' : 'green'}
                      onClick={() => act('radio')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Start Repairs">
                    <Button
                      icon="wrench"
                      disabled={!repairable || data.active}
                      content={!repairable || data.active ? 'Already Repaired' : 'Repair'}
                      onClick={() => act('fix')}
                    />
                  </LabeledList.Item>
                </LabeledList>
                <Box color="green" lineHeight={2}>
                  {data.active ? 'Reconstruction in progress.' : ''}
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
};
