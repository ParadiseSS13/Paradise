import { useBackend } from '../backend';
import { Box, Button, Section, Table, Flex, Icon, Dimmer } from '../components';
import { Window } from '../layouts';
import { BeakerContents } from '../interfaces/common/BeakerContents';

export const ReagentGrinder = (props, context) => {
  return (
    <Window resizable>
      <Window.Content scrollable display="flex" className="Layout__content--flexColumn">
        <Operating/>
        <GrinderControls/>
        <GrinderContents/>
        <GrinderReagents/>
      </Window.Content>
    </Window>
  );
};

const Operating = (props, context) => {
  const { data } = useBackend(context);
  const {
          operating,
          name
        } = data;

  if (operating) {
    return (
      <Dimmer>
        <Flex mb="30px">
          <Flex.Item
            bold
            color="silver"
            textAlign="center">
            <Icon
              name="spinner"
              spin
              size={4}
              mb="15px"
            /><br />
            The {name} is processing...
          </Flex.Item>
        </Flex>
      </Dimmer>
    );
  }
};

const GrinderControls = (props, context) => {
  const { act, data } = useBackend(context);
  const {
          inactive,
        } = data;

  return (
    <Section title="Controls">
      <Flex>
        <Flex.Item width="50%" mr="3px">
          <Button
            fluid
            textAlign="center"
            icon="mortar-pestle"
            disabled={inactive}
            tooltip={inactive ? "There are no contents" : "Grind the contents"}
            tooltipPosition="bottom"
            content="Grind"
            onClick={() => act('grind')}
          />
        </Flex.Item>
        <Flex.Item width="50%">
          <Button
            fluid
            textAlign="center"
            icon="blender"
            disabled={inactive}
            tooltip={inactive ? "There are no contents" : "Juice the contents"}
            tooltipPosition="bottom"
            content="Juice"
            onClick={() => act('juice')}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
}

const GrinderContents = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    contents,
    limit,
    count,
    inactive
  } = data;

  return (
    <Section
        title="Contents"
        flexGrow={1}
        buttons={(
      <Box>
        <Box inline color="label" mr={2}>
          {count} / {limit} items
        </Box>
        <Button
            icon="eject"
            content="Eject Contents"
            onClick={() => act('eject')}
            disabled={inactive}
            tooltip={inactive ? "There are no contents" : ""}
          />
      </Box>
    )}
    >
      <Table>
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
  )
}

const GrinderReagents = (props, context) => {
  const { act, data } = useBackend(context);
  const {
          beaker_loaded,
          beaker_current_volume,
          beaker_max_volume,
          beaker_contents
        } = data;

  return (
    <Section
        title="Beaker"
        flexGrow="1"
        buttons={
      !!beaker_loaded && (
        <Box>
          <Box inline color="label" mr={2}>
            {beaker_current_volume} / {beaker_max_volume} units
          </Box>
          <Button
            icon="eject"
            content="Detach Beaker"
            onClick={() => act('detach')}
          />
        </Box>
      )
    }
    >
    <BeakerContents
      beakerLoaded={beaker_loaded}
      beakerContents={beaker_contents}
    />
    </Section>
  )
}
