import { useBackend, useSharedState } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const AIResourceManagementConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { auth, ai_list, nodes_list } = data;
  return (
    <Window width={500} height={460}>
      <Window.Content scrollable>

      </Window.Content>
    </Window>
  );
};
