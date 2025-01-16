import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack, Tabs, Input } from '../components';
import { Window } from '../layouts';
import { ButtonCheckbox } from '../components/Button';


export const QuirkMenu = (props, context) => {
  return(
    <Window width={700} height={850}>
      <Window.Content>
        <Stack fill horizontal>
          <Quirks context={context}/>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Quirks = ({context}) => {
  const {act, data} = useBackend(context);
  const {quirk_balance, selected_quirks, all_quirks} = data;

  const HasChosenQuirk = (quirk) => {
    return Boolean(selected_quirks && selected_quirks.includes(quirk.name))
  };

  const RenderQuirk = (quirk) => {
    const alreadyChosen = HasChosenQuirk(quirk);
    return (
    <Stack>
        <ButtonCheckbox checked = {alreadyChosen}
          onClick={() => act(alreadyChosen ? 'remove_quirk' : 'add_quirk', {path: quirk.path})}/>
      <Stack vertical>
        <Stack.Item bold>
          {quirk.name}: {quirk.cost}
        </Stack.Item>
        <Stack.Item>
          {quirk.desc}
        </Stack.Item>
      </Stack>
    </Stack>
    );
  };

  return (
  <Section textAlign = 'center'>
    <b>Current quirk balance: {quirk_balance}</b>
      <Stack fill vertical>
        {all_quirks.map(RenderQuirk)}
      </Stack>
  </Section>
  );
};

