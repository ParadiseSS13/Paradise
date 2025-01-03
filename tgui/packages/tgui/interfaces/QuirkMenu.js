import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack, Tabs, Input } from '../components';
import { Window } from '../layouts';
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

  const RenderBalance = () => {
    return  (
      <Stack.Item>
        {parseInt(quirk_balance, 10)}
      </Stack.Item>
    );
  };

  const RenderQuirk = (quirk) => {
    let alreadyChosen = HasChosenQuirk(quirk);
    return (
    <Stack.Item textAlign='center' key = {quirk.quirk_type}>
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
      {RenderBalance()}
    </Stack>
  );
};

