import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotFloor = (props) => {
  const { act, data } = useBackend();
  const { noaccess, painame, hullplating, replace, eat, make, fixfloor, nag_empty, magnet, tiles_amount } = data;
  return (
    <Window width={500} height={510}>
      <Window.Content scrollable>
        <BotStatus />
        <Section title="Floor Settings">
          <Box mb="5px">
            <LabeledList.Item label="Tiles Left">{tiles_amount}</LabeledList.Item>
          </Box>
          <Button.Checkbox
            fluid
            checked={hullplating}
            content="Add tiles to new hull plating"
            tooltip="Fixing a plating requires the removal of floor tile. This will place it back after repairing. Same goes for hull breaches"
            disabled={noaccess}
            onClick={() => act('autotile')}
          />
          <Button.Checkbox
            fluid
            checked={replace}
            content="Add floor tiles on exposed hull plating"
            tooltip="Example: It will add tiles to maintenance"
            disabled={noaccess}
            onClick={() => act('replacetiles')}
          />
          <Button.Checkbox
            fluid
            checked={fixfloor}
            content="Repair damaged tiles and platings"
            disabled={noaccess}
            onClick={() => act('fixfloors')}
          />
        </Section>
        <Section title="Miscellaneous">
          <Button.Checkbox
            fluid
            checked={eat}
            content="Finds tiles"
            disabled={noaccess}
            onClick={() => act('eattiles')}
          />
          <Button.Checkbox
            fluid
            checked={make}
            content="Make pieces of metal into tiles when empty"
            disabled={noaccess}
            onClick={() => act('maketiles')}
          />
          <Button.Checkbox
            fluid
            checked={nag_empty}
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
            <Button.Checkbox fluid icon="eject" content={painame} disabled={noaccess} onClick={() => act('ejectpai')} />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
