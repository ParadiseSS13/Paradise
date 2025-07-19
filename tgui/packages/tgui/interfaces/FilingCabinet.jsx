import { Button, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const FilingCabinet = (props) => {
  const { act, data, config } = useBackend();
  const { contents } = data;
  const { title } = config;
  return (
    <Window width={400} height={300}>
      <Window.Content>
        <Stack fill vertical>
          <Section fill scrollable title="Contents">
            {!contents && (
              <Stack fill>
                <Stack.Item bold grow textAlign="center" align="center" color="average">
                  <Icon.Stack>
                    <Icon name="folder-open" size={5} color="gray" />
                    <Icon name="slash" size={5} color="red" />
                  </Icon.Stack>
                  <br />
                  The {title} is empty.
                </Stack.Item>
              </Stack>
            )}
            {!!contents &&
              contents.slice().map((item) => {
                return (
                  <Stack key={item} mt={0.5} className="candystripe">
                    <Stack.Item width="80%">{item.display_name}</Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-down"
                        content="Retrieve"
                        onClick={() => act('retrieve', { index: item.index })}
                      />
                    </Stack.Item>
                  </Stack>
                );
              })}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
