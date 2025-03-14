import { useBackend, useSharedState } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

export const AIProgramPicker = (props, context) => {
  const { act, data } = useBackend(context);
  const { program_list } = data;
  return (
    <Window width={500} height={461}>
      <Window.Content scrollable />
      <Stack>
        {!!program_list &&
          program_list.map((program, i) => (
            <Section key={program} title={program.name}>
              <LabeledList>
                <LabeledList.Item label="Description">{program.description}</LabeledList.Item>
                <LabeledList.Item label="Memory Cost">{program.memory_cost}</LabeledList.Item>
                <LabeledList.Item label="Installed">{program.installed}</LabeledList.Item>
                <LabeledList.Item label="Upgrade Level">{program.upgrade_level}</LabeledList.Item>
                <LabeledList.Item label="Passive">{program.is_passive}</LabeledList.Item>
              </LabeledList>
            </Section>
          ))}
      </Stack>
    </Window>
  );
};
