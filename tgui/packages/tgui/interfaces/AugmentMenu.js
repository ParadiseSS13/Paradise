import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, LabeledList, Tabs, Icon, Stack} from '../components';
import { Window } from '../layouts';

export const AugmentMenu = (props, context) => {
  return (
    <Window width={700} height={660} title="Augment Menu">
      <Window.Content>
        <Stack fill vertical>
          <Abilities/>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Abilities = (props, context) => {
  const { act, data } = useBackend(context);
  const {usable_swarms, abilities = []} = data;
  return(
    abilities.map((ability, i) => {
    return(
        <Stack
          key = {i}
          title = {ability.name}>
          <Stack.Item p={1}
            key = {i}
            textAlign = "center"
            grow = {1}>
              <Section
                title = {ability.name}
                >
                {ability.desc}
                {ability}
          <Button
            content = {ability.cost} // TODO: Make this change when you buy it
            icon = "minus"
            tooltip = "Purchase this ability?"
            onClick={() => act("purchase", {ability_path: ability.ability_path}
              )}
            textAlign = "right"/>
          </Section>
        </Stack.Item>
      </Stack>

    );
  }));
}

