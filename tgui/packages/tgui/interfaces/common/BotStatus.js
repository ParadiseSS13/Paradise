// ********* COMMON STATUS - GENERAL SETTINGS PAGE FOR BOTS *********
import { useBackend } from '../../backend';
import { Button, LabeledList, NoticeBox, Section, Box } from '../../components';

export const BotStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const { locked, noaccess, maintpanel, on, autopatrol, canhack, emagged, remote_disabled } = data;
  return (
    <>
      <NoticeBox>Swipe an ID card to {locked ? 'unlock' : 'lock'} this interface.</NoticeBox>
      <Section title="General Settings">
        <LabeledList>
          <LabeledList.Item label="Status">
            <Button
              icon={on ? 'power-off' : 'times'}
              content={on ? 'On' : 'Off'}
              selected={on}
              disabled={noaccess}
              onClick={() => act('power')}
            />
          </LabeledList.Item>
          {autopatrol !== null && (
            <LabeledList.Item label="Patrol">
              <Button.Checkbox
                fluid
                checked={autopatrol}
                content="Auto Patrol"
                disabled={noaccess}
                onClick={() => act('autopatrol')}
              />
            </LabeledList.Item>
          )}
          {!!maintpanel && (
            <LabeledList.Item label="Maintenance Panel">
              <Box color="bad">Panel Open!</Box>
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Safety System">
            <Box color={emagged ? 'bad' : 'good'}>{emagged ? 'DISABLED!' : 'Enabled'}</Box>
          </LabeledList.Item>
          {!!canhack && (
            <LabeledList.Item label="Hacking">
              <Button
                icon="terminal"
                content={emagged ? 'Restore Safties' : 'Hack'}
                disabled={noaccess}
                color="bad"
                onClick={() => act('hack')}
              />
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Remote Access">
            <Button.Checkbox
              fluid
              checked={!remote_disabled}
              content="AI Remote Control"
              disabled={noaccess}
              onClick={() => act('disableremote')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};
