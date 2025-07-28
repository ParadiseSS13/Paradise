import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotSecurity = (props) => {
  const { act, data } = useBackend();
  const { noaccess, painame, check_id, check_weapons, check_warrant, arrest_mode, arrest_declare } = data;
  return (
    <Window width={500} height={445}>
      <Window.Content scrollable>
        <BotStatus />
        <Section title="Who To Arrest">
          <Button.Checkbox
            fluid
            checked={check_id}
            content="Unidentifiable Persons"
            disabled={noaccess}
            onClick={() => act('authid')}
          />
          <Button.Checkbox
            fluid
            checked={check_weapons}
            content="Unauthorized Weapons"
            disabled={noaccess}
            onClick={() => act('authweapon')}
          />
          <Button.Checkbox
            fluid
            checked={check_warrant}
            content="Wanted Criminals"
            disabled={noaccess}
            onClick={() => act('authwarrant')}
          />
        </Section>
        <Section title="Arrest Procedure">
          <Button.Checkbox
            fluid
            checked={arrest_mode}
            content="Detain Targets Indefinitely"
            disabled={noaccess}
            onClick={() => act('arrtype')}
          />
          <Button.Checkbox
            fluid
            checked={arrest_declare}
            content="Announce Arrests On Radio"
            disabled={noaccess}
            onClick={() => act('arrdeclare')}
          />
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
