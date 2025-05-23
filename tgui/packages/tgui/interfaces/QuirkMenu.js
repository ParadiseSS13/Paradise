import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack, Tabs, Input, LabeledList } from '../components';
import { Window } from '../layouts';
import { ButtonCheckbox } from '../components/Button';

export const QuirkMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { quirk_balance, selected_quirks, all_quirks } = data;

  const HasChosenQuirk = (quirk) => {
    return Boolean(selected_quirks && selected_quirks.includes(quirk.name));
  };

  const BalanceCheck = (quirk) => {
    return Boolean(quirk_balance + quirk.cost > 0);
  };

  const RenderQuirk = (quirk) => {
    const alreadyChosen = HasChosenQuirk(quirk);
    const canPick = BalanceCheck(quirk);

    return (
      <Section
        key={quirk.name}
        title={quirk.name}
        mb={1}
        buttons={
          <ButtonCheckbox
            checked={alreadyChosen}
            disabled={(canPick && !alreadyChosen) || (alreadyChosen && quirk_balance - quirk.cost > 0)}
            onClick={() => act(alreadyChosen ? 'remove_quirk' : 'add_quirk', { path: quirk.path })}
            mr="10px"
          />
        }
      >
        <LabeledList>
          <Stack vertical>
            <Stack.Item mb={0}>
              <LabeledList.Item label="Cost">{quirk.cost}</LabeledList.Item>
            </Stack.Item>
            <Stack.Item>
              <LabeledList.Item label="Description">{quirk.desc}</LabeledList.Item>
            </Stack.Item>
          </Stack>
        </LabeledList>
      </Section>
    );
  };

  const sortedQuirks = all_quirks.sort((a, b) => a.cost - b.cost);
  return (
    <Window width={500} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Current Quirk Balance" mb={2}>
              <b>{quirk_balance}</b>
            </Section>
          </Stack.Item>
          <Stack.Item grow>{sortedQuirks.map(RenderQuirk)}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
