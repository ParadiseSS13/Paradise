import { Fragment } from 'inferno';
import { useBackend, useSharedState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  NoticeBox,
  Section,
  Tabs,
} from '../components';
import { Window } from '../layouts';

export const RoboticsControlConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { can_hack, safety, show_lock_all, cyborgs = [] } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        {!!show_lock_all && (
          <Section title="Emergency Lock Down">
            <Button
              icon={safety ? 'lock' : 'unlock'}
              content={safety ? 'Disable Safety' : 'Enable Safety'}
              selected={safety}
              onClick={() => act('arm', {})}
            />
            <Button
              icon="lock"
              disabled={safety}
              content="Lock ALL Cyborgs"
              color="bad"
              onClick={() => act('masslock', {})}
            />
          </Section>
        )}
        <Cyborgs cyborgs={cyborgs} can_hack={can_hack} />
      </Window.Content>
    </Window>
  );
};

const Cyborgs = (props, context) => {
  const { cyborgs, can_hack } = props;
  const { act, data } = useBackend(context);
  let detonateText = 'Detonate';
  if (data.detonate_cooldown > 0) {
    detonateText += ' (' + data.detonate_cooldown + 's)';
  }
  if (!cyborgs.length) {
    return (
      <NoticeBox>No cyborg units detected within access parameters.</NoticeBox>
    );
  }
  return cyborgs.map((cyborg) => {
    return (
      <Section
        key={cyborg.uid}
        title={cyborg.name}
        buttons={
          <Fragment>
            {!!cyborg.hackable && !cyborg.emagged && (
              <Button
                icon="terminal"
                content="Hack"
                color="bad"
                onClick={() =>
                  act('hackbot', {
                    uid: cyborg.uid,
                  })
                }
              />
            )}
            <Button.Confirm
              icon={cyborg.locked_down ? 'unlock' : 'lock'}
              color={cyborg.locked_down ? 'good' : 'default'}
              content={cyborg.locked_down ? 'Release' : 'Lockdown'}
              disabled={!data.auth}
              onClick={() =>
                act('stopbot', {
                  uid: cyborg.uid,
                })
              }
            />
            <Button.Confirm
              icon="bomb"
              content={detonateText}
              disabled={!data.auth || data.detonate_cooldown > 0}
              color="bad"
              onClick={() =>
                act('killbot', {
                  uid: cyborg.uid,
                })
              }
            />
          </Fragment>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Status">
            <Box
              color={
                cyborg.status ? 'bad' : cyborg.locked_down ? 'average' : 'good'
              }
            >
              {cyborg.status
                ? 'Not Responding'
                : cyborg.locked_down
                ? 'Locked Down'
                : 'Nominal'}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Location">
            <Box>{cyborg.locstring}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Integrity">
            <ProgressBar
              color={cyborg.health > 50 ? 'good' : 'bad'}
              value={cyborg.health / 100}
            />
          </LabeledList.Item>
          {(typeof cyborg.charge === 'number' && (
            <Fragment>
              <LabeledList.Item label="Cell Charge">
                <ProgressBar
                  color={cyborg.charge > 30 ? 'good' : 'bad'}
                  value={cyborg.charge / 100}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Cell Capacity">
                <Box color={cyborg.cell_capacity < 30000 ? 'average' : 'good'}>
                  {cyborg.cell_capacity}
                </Box>
              </LabeledList.Item>
            </Fragment>
          )) || (
            <LabeledList.Item label="Cell">
              <Box color="bad">No Power Cell</Box>
            </LabeledList.Item>
          )}
          {!!cyborg.is_hacked && (
            <LabeledList.Item label="Safeties">
              <Box color="bad">DISABLED</Box>
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Module">{cyborg.module}</LabeledList.Item>
          <LabeledList.Item label="Master AI">
            <Box color={cyborg.synchronization ? 'default' : 'average'}>
              {cyborg.synchronization || 'None'}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    );
  });
};
