import { useBackend } from '../backend';
import { useSharedState } from '../backend';
import { Box, Button, Section, Table, Stack } from '../components';
import { Window } from '../layouts';
import { BeakerContents } from '../interfaces/common/BeakerContents';
import { Operating } from '../interfaces/common/Operating';
import { NumberInput } from '../components';
import { LabeledList } from '../components';
import { Icon } from '../components';

export const ReagentGrinder = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { operating, reagent_storage } = data;
  const { title } = config;
  return (
    <Window
      width={reagent_storage ? 550 : 400}
      height={reagent_storage ? 900 : 565}
    >
      <Window.Content>
        <Stack fill vertical>
          <Operating operating={operating} name={title} />
          <GrinderControls />
          <GrinderContents />
          {reagent_storage ? <TankReagents /> : ''}
          <BeakerReagents />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const GrinderControls = (props, context) => {
  const { act, data } = useBackend(context);
  const { inactive, reagent_storage } = data;

  return (
    <Section title="Controls">
      <Stack>
        <Stack.Item width="50%">
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
        <Stack.Item width="50%">
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

const GrinderContents = (props, context) => {
  const { act, data } = useBackend(context);
  const { contents, limit, count, inactive } = data;

  return (
    <Section
      title="Contents"
      fill
      height="60%"
      scrollable
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

const TankReagents = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beaker_loaded,
    beaker_max_volume,
    tank_current_volume,
    tank_max_volume,
    tank_contents,
  } = data;

  let [dispenseAmount, setDispenseAmount] = useSharedState(
    context,
    'dispenseAmount',
    1
  );

  return (
    <Section
      title="Tank"
      fill
      scrollable
      height="80%"
      buttons={
        <Box>
          <Box inline color="label" mr={2}>
            {tank_current_volume} / {tank_max_volume} units
          </Box>
          <Button
            content="Clear Tank"
            color="red"
            tooltip="completely empty the internal tank"
            onClick={() => act('clear')}
          />
          <Button
            content="Dispense Mix"
            tooltip="Dispense a proportional mix of the tank's contents"
            onClick={() => act('dispense_mix', { amount: dispenseAmount })}
          />
          <NumberInput
            width="40px"
            minValue={0}
            value={dispenseAmount}
            maxValue={beaker_loaded ? beaker_max_volume : 0}
            step={1}
            stepPixelSize={3}
            onChange={(e, value) => setDispenseAmount(value)}
          />
        </Box>
      }
    >
      <Stack fill vertical>
        <Section fill scrollable title={'Reagents'}>
          {!tank_contents && (
            <Stack fill>
              <Stack.Item
                bold
                grow
                textAlign="center"
                align="center"
                color="average"
              >
                <Icon.Stack>
                  <Icon name="flask" size={5} color="green" />
                  <Icon name="slash" size={5} color="red" />
                </Icon.Stack>
                <br />
                The Botanitank is empty.
              </Stack.Item>
            </Stack>
          )}
          {!!tank_contents &&
            tank_contents
              .slice()
              .sort((a, b) => a.display_name.localeCompare(b.display_name))
              .map((item) => {
                return (
                  <Stack key={item}>
                    <Stack.Item width="30%">{item.display_name}</Stack.Item>
                    <Stack.Item width="35%">
                      ({item.quantity} u in tank)
                    </Stack.Item>
                    <Stack.Item width={20}>
                      <Button
                        width={4}
                        icon="arrow-down"
                        tooltip="Dispense the set amount"
                        content={dispenseAmount}
                        onClick={() =>
                          act('dispense', {
                            index: item.dispense,
                            amount: dispenseAmount,
                          })
                        }
                      />
                      <Button
                        width={4}
                        icon="arrow-down"
                        content="All"
                        tooltip="Dispense all."
                        tooltipPosition="bottom-start"
                        onClick={() =>
                          act('dispense', {
                            index: item.dispense,
                            amount: item.quantity,
                          })
                        }
                      />
                      <Button
                        width={4}
                        icon="arrow-down"
                        color="red"
                        content={dispenseAmount}
                        tooltip="Dump the set amount"
                        tooltipPosition="bottom-start"
                        onClick={() =>
                          act('dump', {
                            index: item.dispense,
                            amount: dispenseAmount,
                          })
                        }
                      />
                      <Button
                        width={4}
                        icon="arrow-down"
                        color="red"
                        content="All"
                        tooltip="Dump All"
                        tooltipPosition="bottom-start"
                        onClick={() =>
                          act('dump', {
                            index: item.dispense,
                            amount: item.quantity,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                );
              })}
        </Section>
      </Stack>
    </Section>
  );
};

const BeakerReagents = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beaker_loaded,
    beaker_current_volume,
    beaker_max_volume,
    beaker_contents,
  } = data;

  return (
    <Section
      title="Beaker"
      fill
      scrollable
      height="40%"
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
  );
};
