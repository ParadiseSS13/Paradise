import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack, Tabs, Input } from '../components';
import { ButtonCheckbox } from '../components/Button';


export const QuirkMenu = (props, context) => {
  return(
    <Window>
      <Window.Content>
        <Stack fill vertical>
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
    return (selected_quirks && selected_quirks.includes(quirk.name))
  };

  const RenderQuirk = (quirk) => {
    const alreadyChosen = HasChosenQuirk(quirk);
    return (
    <Stack.Item textAlign='center' key = {quirk.quirk_type}>
      {quirk.name}: {quirk.cost} balance cost
      <ButtonCheckbox checked = {alreadyChosen}
      onClick={() => act(alreadyChosen ? 'remove_quirk' : 'add_quirk', {path: quirk.type})}/>
      <Box>
        {quirk.desc}
      </Box>
    </Stack.Item>
    );
  };

  return (
    <Stack>
      Quirk balance: {quirk_balance}
    {
    all_quirks.map((quirk) => {
      RenderQuirk(quirk)})
    }
    </Stack>
  );
};

