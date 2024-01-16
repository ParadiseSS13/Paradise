import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section } from '../components';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotHonk = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable>
      <Window.Content scrollable>
        <BotStatus />
      </Window.Content>
    </Window>
  );
};
