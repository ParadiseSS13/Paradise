import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section } from '../components';
import { Window } from '../layouts';

export const DSManager = (props, context) => {
  const { act, data } = useBackend(context);
  let slotOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
  return (
    <Window>
      <Window.Content>
        <Section title="Overview">
          <LabeledList>
            <LabeledList.Item
              label="Current Alert"
              color={data.security_level_color}
            >
              {data.str_security_level}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Slots">
            <LabeledList>
            <LabeledList.Item label="Deathsquad">
              {slotOptions.map((a, i) => (
                <Button
                  key={'squad' + a}
                  selected={data.squad === a}
                  content={a}
                  onClick={() =>
                    act('set_squad', {
                      set_sec: a,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Total Slots">
              <Box color={data.squad > data.spawnpoints ? 'red' : 'green'}>
                {data.squad} squad, versus {data.spawnpoints} spawnpoints
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Safety">
              <Button
                icon={data.safety ? 'check' : 'times'}
                selected={data.safety}
                content={data.safety ? 'ON' : 'OFF'}
                tooltip={data.safety ? 'Disable Safety' : 'Enable Safety'}
                onClick={() => act('toggle_safety')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Dispatch">
              <Button
                icon={'bomb'}
                disabled={data.safety}
                color="red"
                content={'SEND IN THE DEATHSQUAD'}
                onClick={() => act('dispatch_ds')}
              />
            </LabeledList.Item>
            </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

