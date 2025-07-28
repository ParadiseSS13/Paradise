import { Box, Button, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';
import { Operating } from './common/Operating';

export const ReagentGrinder = (props) => {
  const { act, data, config } = useBackend();
  const { operating } = data;
  const { title } = config;
  return (
    <Window width={400} height={565}>
      <Window.Content>
        <Stack fill vertical>
          <Operating operating={operating} name={title} />
          <Stack.Item>
            <GrinderControls />
          </Stack.Item>
          <Stack.Item grow>
            <GrinderContents />
          </Stack.Item>
          <Stack.Item height="30%">
            <GrinderReagents />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const GrinderControls = (props) => {
  const { act, data } = useBackend();
  const { inactive } = data;

  return (
    <Section title="Controls">
      <Stack>
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            icon="mortar-pestle"
            disabled={inactive}
            tooltip={inactive ? 'There are no contents' : 'Grind the contents'}
            tooltipPosition="bottom"
            content="Grind"
            onClick={() => act('grind')}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            icon="blender"
            disabled={inactive}
            tooltip={inactive ? 'There are no contents' : 'Juice the contents'}
            tooltipPosition="bottom"
            content="Juice"
            onClick={() => act('juice')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const GrinderContents = (props) => {
  const { act, data } = useBackend();
  const { contents, limit, count, inactive } = data;

  return (
    <Section
      fill
      scrollable
      title="Contents"
      buttons={
        <Box>
          <Box inline color="label" mr={2}>
            {count} / {limit} items
          </Box>
          <Button
            icon="eject"
            content="Eject Contents"
            onClick={() => act('eject')}
            disabled={inactive}
            tooltip={inactive ? 'There are no contents' : ''}
          />
        </Box>
      }
    >
      <Table className="Ingredient__Table">
        {contents.map((content) => (
          <Table.Row tr={5} key={content.name}>
            <td>
              <Table.Cell bold>{content.name}</Table.Cell>
            </td>
            <td>
              <Table.Cell collapsing textAlign="center">
                {content.amount} {content.units}
              </Table.Cell>
            </td>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const GrinderReagents = (props) => {
  const { act, data } = useBackend();
  const { beaker_loaded, beaker_current_volume, beaker_max_volume, beaker_contents } = data;

  return (
    <Section
      fill
      scrollable
      title="Beaker"
      buttons={
        !!beaker_loaded && (
          <Box>
            <Box inline color="label" mr={2}>
              {beaker_current_volume} / {beaker_max_volume} units
            </Box>
            <Button icon="eject" content="Detach Beaker" onClick={() => act('detach')} />
          </Box>
        )
      }
    >
      <BeakerContents beakerLoaded={beaker_loaded} beakerContents={beaker_contents} />
    </Section>
  );
};
