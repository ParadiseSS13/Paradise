import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Box } from '../components';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotClean = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    noaccess,
    painame,
    cleanblood,
  } = data;
  return (
    <Window>
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
        {painame && (
          <Section title="pAI">
            <Button
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
