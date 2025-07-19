import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotClean = (props) => {
  const { act, data } = useBackend();
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
            <Box mb={1}>
              <LabeledList>
                <LabeledList.Item label="Locked Area">{area}</LabeledList.Item>
              </LabeledList>
            </Box>
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
