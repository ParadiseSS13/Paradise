import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const AIProgramPicker = (props) => {
  const { act, data } = useBackend();
  const { program_list, ai_info } = data;
  return (
    <Window width={450} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Select Program">
              <LabeledList>
                <LabeledList.Item label="Memory Available">{ai_info.memory}</LabeledList.Item>
                <LabeledList.Item label="Bandwidth Available">{ai_info.bandwidth}</LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {!!program_list &&
              program_list.map((program, i) => (
                <Section
                  key={program}
                  title={program.name}
                  mb={1}
                  buttons={
                    <Button icon="file" onClick={() => act('select', { uid: program.UID })}>
                      {program.installed === 1 ? 'Update' : 'Install'}
                    </Button>
                  }
                >
                  <Stack vertical>
                    <LabeledList>
                      <Stack.Item mb={2}>
                        <LabeledList.Item label="Description">{program.description}</LabeledList.Item>
                      </Stack.Item>
                      <Stack>
                        <Stack.Item>
                          <LabeledList.Item label={program.installed === 1 ? 'Bandwidth Cost' : 'Memory Cost'}>
                            {program.memory_cost}
                          </LabeledList.Item>
                          <LabeledList.Item label="Upgrade Level">{program.upgrade_level}</LabeledList.Item>
                        </Stack.Item>
                        <Stack.Item>
                          <LabeledList.Item label="Installed">
                            {program.installed === 1 ? 'True' : 'False'}
                          </LabeledList.Item>
                          <LabeledList.Item label="Passive">
                            {program.is_passive === 1 ? 'True' : 'False'}
                          </LabeledList.Item>
                        </Stack.Item>
                      </Stack>
                    </LabeledList>
                  </Stack>
                </Section>
              ))}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
