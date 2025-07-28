import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const NuclearBomb = (props) => {
  const { act, data } = useBackend();

  if (!data.extended) {
    return (
      <Window width={350} height={115}>
        <Window.Content>
          <Section title="Deployment">
            <Button
              fluid
              icon="exclamation-triangle"
              content="Deploy Nuclear Device (will bolt device to floor)"
              onClick={() => act('deploy')}
            />
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={350} height={290}>
      <Window.Content>
        <Section title="Authorization">
          <LabeledList>
            <LabeledList.Item label="Auth Disk">
              <Button
                icon={data.authdisk ? 'eject' : 'id-card'}
                selected={data.authdisk}
                content={data.diskname ? data.diskname : '-----'}
                tooltip={data.authdisk ? 'Eject Disk' : 'Insert Disk'}
                onClick={() => act('auth')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Auth Code">
              <Button
                icon="key"
                disabled={!data.authdisk}
                selected={data.authcode}
                content={data.codemsg}
                onClick={() => act('code')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Arming & Disarming">
          <LabeledList>
            <LabeledList.Item label="Bolted to floor">
              <Button
                icon={data.anchored ? 'check' : 'times'}
                selected={data.anchored}
                disabled={!data.authdisk}
                content={data.anchored ? 'YES' : 'NO'}
                onClick={() => act('toggle_anchor')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Time Left">
              <Button
                icon="stopwatch"
                content={data.time}
                disabled={!data.authfull}
                tooltip="Set Timer"
                onClick={() => act('set_time')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Safety">
              <Button
                icon={data.safety ? 'check' : 'times'}
                selected={data.safety}
                disabled={!data.authfull}
                content={data.safety ? 'ON' : 'OFF'}
                tooltip={data.safety ? 'Disable Safety' : 'Enable Safety'}
                onClick={() => act('toggle_safety')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Arm/Disarm">
              <Button
                icon={data.timer ? 'bomb' : 'bomb'}
                disabled={data.safety || !data.authfull}
                color="red"
                content={data.timer ? 'DISARM THE NUKE' : 'ARM THE NUKE'}
                onClick={() => act('toggle_armed')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
