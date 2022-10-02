import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Box,
} from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

export const BotFloor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    locked,
    noaccess,
    maintpanel,
    on,
    autopatrol,
    painame,
    canhack,
    emagged,
    remote_disabled,
    hullplating,
    replace,
    repair,
    find,
    alert,
    magnet,
    tiles,
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
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Patrol">
              <Button.Checkbox
                fluid
                checked={autopatrol}
                content="Auto Patrol"
                disabled={noaccess}
                onClick={() => act('autopatrol')}
              />
            </LabeledList.Item>
            {!!maintpanel && (
              <LabeledList.Item label="Maintenance Panel">
                <Box color="bad">Panel Open!</Box>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Safety System">
              <Box color={emagged ? 'bad' : 'good'}>
                {emagged ? 'DISABLED!' : 'Enabled'}
              </Box>
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
        <Section title="Floor Settings">
          <LabeledList>
            <LabeledList.Item label="Tiles Left">
              {tiles}
            </LabeledList.Item>
          </LabeledList>
          <Button.Checkbox
            fluid
            checked={hullplating}
            content="Add tiles to new hull plating"
            disabled={noaccess}
            onClick={() => act('autotile')}
          />
          <Button.Checkbox
            fluid
            checked={replace}
            content="Replace floor tiles"
            disabled={noaccess}
            onClick={() => act('replacetiles')}
          />
          <Button.Checkbox
            fluid
            checked={repair}
            content="Repair damaged tiles and platings"
            disabled={noaccess}
            onClick={() => act('fixfloors')}
          />
        </Section>
        <Section title = "Miscellaneous">
          <Button.Checkbox
            fluid
            checked={find}
            content="Finds tiles"
            disabled={noaccess}
            onClick={() => act('eattiles')}
          />
          <Button.Checkbox
            fluid
            checked={alert}
            content="Transmit notice when empty"
            disabled={noaccess}
            onClick={() => act('nagonempty')}
          />
          <Button.Checkbox
          fluid
          checked={magnet}
          content="Traction Magnets"
          disabled={noaccess}
          onClick={() => act('anchored')}
        />
        </Section>
        {painame && (
          <Section title="pAI">
            <Button.Ch
              fluid
              icon="eject"
              content={painame}
              disabled={noaccess}
              onClick={() => act('ejectpai')}
            />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
