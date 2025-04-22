import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section } from '../components';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotHonk = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={500} height={220}>
      <Window.Content scrollable>
        <BotStatus />
      </Window.Content>
    </Window>
  );
};
