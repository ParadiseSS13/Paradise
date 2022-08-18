import { useBackend } from '../backend';
import {
  Button,
  ProgressBar,
  LabeledList,
  Section,
} from '../components';
import { Window } from '../layouts';

export const PrisonerShuttleConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    can_go_home,
    emagged,
    id_inserted,
    id_name,
    id_points,
    id_goal,
  } = data;
  const bad_progress = emagged ? 0 : 1;
  const completionStatus = emagged
    ? 'ERR0R'
    : can_go_home
    ? 'Completed!'
    : 'Insufficient';
  return (
    <Window>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Status">
            {(!!id_inserted && (
              <ProgressBar
                value={id_points / id_goal}
                ranges={{
                  good: [bad_progress, Infinity],
                  bad: [-Infinity, bad_progress],
                }}
              >
                {id_points + ' / ' + id_goal + ' ' + completionStatus}
              </ProgressBar>
            )) ||
              (!!emagged && 'ERR0R COMPLETED?!@') ||
              'No ID inserted'}
          </LabeledList.Item>
          <LabeledList.Item label="Shuttle controls">
            <Button
              fluid
              content="Move shuttle"
              disabled={!can_go_home}
              onClick={() => act('move_shuttle')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Inserted ID">
            <Button
              fluid
              content={id_inserted ? id_name : '-------------'}
              onClick={() => act('handle_id')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
