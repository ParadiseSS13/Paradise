import { useBackend, useSharedState } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const AIProgramPicker = (props, context) => {
  const { act, data } = useBackend(context);
  const { program_list } = data;
  return (
    <Window width={500} height={460}>
      <Window.Content scrollable />
    </Window>
  );
};
