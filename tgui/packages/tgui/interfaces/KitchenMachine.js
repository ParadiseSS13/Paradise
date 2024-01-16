import { useBackend } from '../backend';
import { Button, Section, Table, Flex, Icon, Dimmer } from '../components';
import { Window } from '../layouts';
import { Operating } from '../interfaces/common/Operating';

export const KitchenMachine = (props, context) => {
  const { data, config } = useBackend(context);
  const { ingredients, operating } = data;
  const { title } = config;

  return (
    <Window resizable>
      <Window.Content
        scrollable
        display="flex"
        className="Layout__content--flexColumn"
      >
        <Operating operating={operating} name={title} />
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
