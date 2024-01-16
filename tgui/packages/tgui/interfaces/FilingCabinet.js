import { useBackend } from '../backend';
import { Box, Section, Button, Flex } from '../components';
import { Window } from '../layouts';

export const FilingCabinet = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { contents } = data;
  const { title } = config;
  return (
    <Window>
      <Window.Content scrollable>
        <Section title="Contents">
          {!contents && <Box color="average"> The {title} is empty. </Box>}
          {!!contents &&
            contents.slice().map((item) => {
              return (
                <Flex direction="row" key={item}>
                  <Flex.Item width="80%">{item.display_name}</Flex.Item>
                  <Flex.Item>
                    <Button
                      icon="arrow-down"
                      content="Retrieve"
                      onClick={() => act('retrieve', { index: item.index })}
                    />
                  </Flex.Item>
                </Flex>
              );
            })}
        </Section>
      </Window.Content>
    </Window>
  );
};
