import { useBackend } from '../backend';
import { Button, Section, Table, Flex, Icon, Dimmer } from '../components';
import { Window } from '../layouts';

export const KitchenMachine = (props, context) => {
  const { data } = useBackend(context);
  const { ingredients } = data;

  return (
    <Window resizable>
      <Window.Content
        scrollable
        display="flex"
        className="Layout__content--flexColumn"
      >
        <Operating />
        <KitchenTop />
        <Section title="Ingredients" flexGrow={1}>
          <Table className="Ingredient__Table">
            {ingredients.map((product) => (
              <Table.Row tr={5} key={product.name}>
                <td>
                  <Table.Cell bold>{product.name}</Table.Cell>
                </td>
                <td>
                  <Table.Cell collapsing textAlign="center">
                    {product.amount} {product.units}
                  </Table.Cell>
                </td>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

const KitchenTop = (props, context) => {
  const { act, data } = useBackend(context);
  const { inactive, tooltip } = data;

  return (
    <Section title="Controls">
      <Flex>
        <Flex.Item width="50%" mr="3px">
          <Button
            fluid
            textAlign="center"
            icon="power-off"
            disabled={inactive}
            tooltip={inactive ? tooltip : ''}
            tooltipPosition="bottom"
            content="Activate"
            onClick={() => act('cook')}
          />
        </Flex.Item>
        <Flex.Item width="50%">
          <Button
            fluid
            textAlign="center"
            icon="eject"
            disabled={inactive}
            tooltip={inactive ? tooltip : ''}
            tooltipPosition="bottom"
            content="Eject Contents"
            onClick={() => act('eject')}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const Operating = (props, context) => {
  const { data } = useBackend(context);
  const { operating, name } = data;

  if (operating) {
    return (
      <Dimmer>
        <Flex mb="30px">
          <Flex.Item bold color="silver" textAlign="center">
            <Icon name="spinner" spin size={4} mb="15px" />
            <br />
            The {name} is processing...
          </Flex.Item>
        </Flex>
      </Dimmer>
    );
  }
};
