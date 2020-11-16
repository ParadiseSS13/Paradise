import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Box } from '../components';
import { Window } from '../layouts';

export const BotClean = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    locked,
    noaccess,
    maintpanel,
    on,
    autopatrol,
    canhack,
    emagged,
    remote_disabled,
    painame,
    cleanblood,
  } = data;
  return (
    <Window>
      <Window.Content scrollable>
        <NoticeBox>
          Swipe an ID card to {locked ? 'unlock' : 'lock'} this interface.
        </NoticeBox>
        <Section title="General Settings">
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'On' : 'Off'}
                selected={on}
                disabled={noaccess}
                onClick={() => act('power')} />
            </LabeledList.Item>
            <LabeledList.Item label="Patrol">
              <Button.Checkbox
                fluid
                checked={autopatrol}
                content="Auto Patrol"
                disabled={noaccess}
                onClick={() => act('autopatrol')} />
            </LabeledList.Item>
            {!!maintpanel && (
              <LabeledList.Item label="Maintenance Panel">
                <Box color="bad">
                  Panel Open!
                </Box>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Safety System">
              <Box color={emagged ? 'bad' : 'good'}>
                {emagged ? "DISABLED!" : "Enabled"}
              </Box>
            </LabeledList.Item>
            {!!canhack && (
              <LabeledList.Item label="Hacking">
                <Button
                  icon="terminal"
                  content={emagged ? "Restore Safties" : "Hack"}
                  disabled={noaccess}
                  color="bad"
                  onClick={() => act('hack')} />
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Remote Access">
              <Button.Checkbox
                fluid
                checked={!remote_disabled}
                content="AI Remote Control"
                disabled={noaccess}
                onClick={() => act('disableremote')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Cleaning Settings">
          <Button.Checkbox
            fluid
            checked={cleanblood}
            content="Clean Blood"
            disabled={noaccess}
            onClick={() => act('blood')} />
        </Section>
        {painame && (
          <Section title="pAI">
            <Button
              fluid
              icon="eject"
              content={painame}
              disabled={noaccess}
              onClick={() => act('ejectpai')} />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
