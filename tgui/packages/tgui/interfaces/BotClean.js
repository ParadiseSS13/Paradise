import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

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
    <Window width={500} height={310}>
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
