import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const KeycardAuth = (props) => {
  const { act, data } = useBackend();
  let infoBox = (
    <Section title="Keycard Authentication Device">
      <Box>
        This device is used to trigger certain high security events. It requires the simultaneous swipe of two
        high-level ID cards.
      </Box>
    </Section>
  );
  if (!data.swiping && !data.busy) {
    return (
      <Window width={540} height={280}>
        <Window.Content>
          {infoBox}
          <Section title="Choose Action">
            <LabeledList>
              <LabeledList.Item label="Red Alert">
                <Button
                  icon="exclamation-triangle"
                  disabled={!data.redAvailable}
                  onClick={() => act('triggerevent', { 'triggerevent': 'Red Alert' })}
                  content="Red Alert"
                />
              </LabeledList.Item>
              <LabeledList.Item label="ERT">
                <Button
                  icon="broadcast-tower"
                  onClick={() =>
                    act('triggerevent', {
                      'triggerevent': 'Emergency Response Team',
                    })
                  }
                  content="Call ERT"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Emergency Maint Access">
                <Button
                  icon="door-open"
                  onClick={() =>
                    act('triggerevent', {
                      'triggerevent': 'Grant Emergency Maintenance Access',
                    })
                  }
                  content="Grant"
                />
                <Button
                  icon="door-closed"
                  onClick={() =>
                    act('triggerevent', {
                      'triggerevent': 'Revoke Emergency Maintenance Access',
                    })
                  }
                  content="Revoke"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Emergency Station-Wide Access">
                <Button
                  icon="door-open"
                  onClick={() =>
                    act('triggerevent', {
                      'triggerevent': 'Activate Station-Wide Emergency Access',
                    })
                  }
                  content="Grant"
                />
                <Button
                  icon="door-closed"
                  onClick={() =>
                    act('triggerevent', {
                      'triggerevent': 'Deactivate Station-Wide Emergency Access',
                    })
                  }
                  content="Revoke"
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {
    let swipeInfo = <Box color="red">Waiting for YOU to swipe your ID...</Box>;
    if (!data.hasSwiped && !data.ertreason && data.event === 'Emergency Response Team') {
      swipeInfo = <Box color="red">Fill out the reason for your ERT request.</Box>;
    } else if (data.hasConfirm) {
      swipeInfo = <Box color="green">Request Confirmed!</Box>;
    } else if (data.isRemote) {
      swipeInfo = <Box color="orange">Swipe your card to CONFIRM the remote request.</Box>;
    } else if (data.hasSwiped) {
      swipeInfo = <Box color="orange">Waiting for second person to confirm...</Box>;
    }
    return (
      <Window width={540} height={265}>
        <Window.Content>
          {infoBox}
          {data.event === 'Emergency Response Team' && (
            <Section title="Reason for ERT Call">
              <Box>
                <Button
                  color={data.ertreason ? '' : 'red'}
                  icon={data.ertreason ? 'check' : 'pencil-alt'}
                  content={data.ertreason ? data.ertreason : '-----'}
                  disabled={data.busy}
                  onClick={() => act('ert')}
                />
              </Box>
            </Section>
          )}
          <Section
            title={data.event}
            buttons={
              <Button
                icon="arrow-circle-left"
                content="Back"
                disabled={data.busy || data.hasConfirm}
                onClick={() => act('reset')}
              />
            }
          >
            {swipeInfo}
          </Section>
        </Window.Content>
      </Window>
    );
  }
};
