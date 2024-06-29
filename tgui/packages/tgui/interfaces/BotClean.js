import { useBackend } from '../backend';
import { Button, Section, Box, LabeledList } from '../components';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotClean = (props, context) => {
  const { act, data } = useBackend(context);
  const { locked, noaccess, maintpanel, on, autopatrol, canhack, emagged, remote_disabled, painame, cleanblood, area } =
    data;
  return (
    <Window width={500} height={400}>
      <Window.Content scrollable>
        <BotStatus />
        <Section title="Cleaning Settings">
          <Button.Checkbox
            fluid
            checked={cleanblood}
            content="Clean Blood"
            disabled={noaccess}
            onClick={() => act('blood')}
          />
        </Section>
        <Section title="Misc Settings">
          <Button
            fluid
            content={area ? 'Reset Area Selection' : 'Restrict to Current Area'}
            onClick={() => act('area')}
          />
          {area !== null && (
            <LabeledList mb={1}>
              <LabeledList.Item label="Locked Area">{area}</LabeledList.Item>
            </LabeledList>
          )}
        </Section>
        {painame && (
          <Section title="pAI">
            <Button fluid icon="eject" content={painame} disabled={noaccess} onClick={() => act('ejectpai')} />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
