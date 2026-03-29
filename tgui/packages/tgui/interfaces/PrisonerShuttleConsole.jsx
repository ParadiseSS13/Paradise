import { Button, LabeledList, ProgressBar } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const PrisonerShuttleConsole = (props) => {
  const { act, data } = useBackend();
  const { can_go_home, emagged, id_inserted, id_name, id_points, id_goal } = data;
  const bad_progress = emagged ? 0 : 1;
  let completionStatus = can_go_home ? 'Completed!' : 'Insufficient';
  if (emagged) {
    completionStatus = 'ERR0R';
  }
  let statusBlock = 'No ID inserted';
  if (id_inserted) {
    statusBlock = (
      <ProgressBar
        value={id_points / id_goal}
        ranges={{
          good: [bad_progress, Infinity],
          bad: [-Infinity, bad_progress],
        }}
      >
        {id_points + ' / ' + id_goal + ' ' + completionStatus}
      </ProgressBar>
    );
  } else if (emagged) {
    statusBlock = 'ERR0R COMPLETED?!@';
  }
  return (
    <Window width={315} height={150}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Status">{statusBlock}</LabeledList.Item>
          <LabeledList.Item label="Shuttle controls">
            <Button fluid content="Move shuttle" disabled={!can_go_home} onClick={() => act('move_shuttle')} />
          </LabeledList.Item>
          <LabeledList.Item label="Inserted ID">
            <Button fluid content={id_inserted ? id_name : '-------------'} onClick={() => act('handle_id')} />
          </LabeledList.Item>
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
