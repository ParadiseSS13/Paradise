import { Button, Dropdown, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ListDisplay } from './RankedListInputModal';

type Data = {
  available_genders: string[];
  available_species: string[];
  chosen_gender: string;
  chosen_species: string;
  ranked_roles: string[];
  time_remaining_secs: number;
};

export const ERTResponseForm = () => {
  const { data, act } = useBackend<Data>();
  const { available_genders, ranked_roles, available_species, time_remaining_secs, chosen_gender, chosen_species } =
    data;

  return (
    <Window width={600} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <Button onClick={() => act('submit_prefs')} color="green" p={2} m={3}>
                  <h1>Submit</h1>
                </Button>
              </Stack.Item>
              <Stack.Item>
                <h1>Choose your ERT preferences below and press Submit.</h1>
                <h2>{time_remaining_secs} seconds remaining.</h2>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Please select a gender">
                <Dropdown
                  selected={chosen_gender}
                  options={available_genders}
                  onSelected={(value) => act('set_gender', { value })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Please select a species">
                <Dropdown
                  selected={chosen_species}
                  options={available_species}
                  onSelected={(value) => act('set_species', { value })}
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
          <Stack.Item height={100}>
            <Section title="Role Preferences">Please order ERT roles from most to least preferred.</Section>
            <ListDisplay filteredItems={ranked_roles} setEditedItems={(items) => act('set_roles', { items })} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
