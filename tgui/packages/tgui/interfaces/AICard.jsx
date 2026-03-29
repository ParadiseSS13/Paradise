import { Box, Button, LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const AICard = (props) => {
  const { act, data } = useBackend();
  if (data.has_ai === 0) {
    return (
      <Window width={250} height={120}>
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
    if (data.integrity >= 75) {
      integrityColor = 'green';
    } else if (data.integrity >= 25) {
      integrityColor = 'yellow';
    } else {
      integrityColor = 'red';
    }

    return (
      <Window width={600} height={420}>
        <Window.Content scrollable>
          <Stack fill vertical>
            <Stack.Item>
              <Section title={data.name}>
                <LabeledList>
                  <LabeledList.Item label="Integrity">
                    <ProgressBar color={integrityColor} value={data.integrity / 100} />
                  </LabeledList.Item>
                </LabeledList>
                <Box color="red">
                  <h2>{data.flushing === 1 ? 'Wipe of AI in progress...' : ''}</h2>
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill scrollable title="Laws">
                {(!!data.has_laws && (
                  <Box>
                    {data.laws.map((value, key) => (
                      <Box key={key}>{value}</Box>
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
                      width={10}
                      icon={data.wireless ? 'check' : 'times'}
                      content={data.wireless ? 'Enabled' : 'Disabled'}
                      color={data.wireless ? 'green' : 'red'}
                      onClick={() => act('wireless')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Subspace Transceiver">
                    <Button
                      width={10}
                      icon={data.radio ? 'check' : 'times'}
                      content={data.radio ? 'Enabled' : 'Disabled'}
                      color={data.radio ? 'green' : 'red'}
                      onClick={() => act('radio')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Wipe">
                    <Button.Confirm
                      width={10}
                      icon="trash-alt"
                      confirmIcon="trash-alt"
                      disabled={data.flushing || data.integrity === 0}
                      confirmColor="red"
                      content="Wipe AI"
                      onClick={() => act('wipe')}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
};
