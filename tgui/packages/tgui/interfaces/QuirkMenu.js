import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack, Tabs, Input } from '../components';
import { Window } from '../layouts';
import { ButtonCheckbox } from '../components/Button';

export const QuirkMenu = (props, context) => {
  return (
    <Window width={625} height={540}>
      <Window.Content>
        <Stack fill horizontal>
          <Quirks context={context} />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Quirks = ({ context }) => {
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
      <div>
        <Stack horizontal align="center">
          <ButtonCheckbox
            checked={alreadyChosen}
            disabled={(canPick && !alreadyChosen) || (alreadyChosen && (quirk_balance - quirk.cost > 0))}
            onClick={() => act(alreadyChosen ? 'remove_quirk' : 'add_quirk', { path: quirk.path })}
            mr="10px"
          />
          <Stack horizontal align="center" justify="start" style={{ width: '100%' }}>
            <Stack.Item mr="35px">
              {quirk.name}: {quirk.cost}
            </Stack.Item>
            <Stack.Item mr="10px">
              {quirk.desc}
            </Stack.Item>
          </Stack>
        </Stack>
        <hr />
      </div>
    );
  };

  return (
    <Section textAlign="center">
      <b>Current quirk balance: {quirk_balance}</b>
      <hr />
      <Stack fill vertical>
        {all_quirks.map(RenderQuirk)}
      </Stack>
    </Section>
  );
};
