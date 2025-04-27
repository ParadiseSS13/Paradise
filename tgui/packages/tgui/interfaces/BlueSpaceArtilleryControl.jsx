import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const BlueSpaceArtilleryControl = (props) => {
  const { act, data } = useBackend();
  let alertStatus;
  if (data.ready) {
    alertStatus = (
      <LabeledList.Item label="Status" color="green">
        Ready
      </LabeledList.Item>
    );
  } else if (data.reloadtime_text) {
    alertStatus = (
      <LabeledList.Item label="Reloading In" color="red">
        {data.reloadtime_text}
      </LabeledList.Item>
    );
  } else {
    alertStatus = (
      <LabeledList.Item label="Status" color="red">
        No cannon connected!
      </LabeledList.Item>
    );
  }
  return (
    <Window width={400} height={150}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill scrollable>
              <LabeledList>
                {data.notice && (
                  <LabeledList.Item label="Alert" color="red">
                    {data.notice}
                  </LabeledList.Item>
                )}
                {alertStatus}
                <LabeledList.Item label="Target">
                  <Button
                    icon="crosshairs"
                    content={data.target ? data.target : 'None'}
                    onClick={() => act('recalibrate')}
                  />
                </LabeledList.Item>
                {data.ready === 1 && !!data.target && (
                  <LabeledList.Item label="Firing">
                    <Button icon="skull" content="FIRE!" color="red" onClick={() => act('fire')} />
                  </LabeledList.Item>
                )}
                {!data.connected && (
                  <LabeledList.Item label="Maintenance">
                    <Button icon="wrench" content="Complete Deployment" onClick={() => act('build')} />
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
