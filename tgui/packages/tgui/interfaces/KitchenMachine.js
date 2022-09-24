import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Table, Flex, Icon, Dimmer } from '../components';
import { Window } from '../layouts';

export const KitchenMachine = (props, context) => {
  const { data } = useBackend(context);
  const { ingredients = [],
          name
        } = data;

  return (
    <Window title= {name} resizable>
      <Window.Content scrollable display="flex" className="Layout__content--flexColumn">
        <Operating/>
        <KitchenTop/>
        <Section title="Ingredients">
          <Table>
            {ingredients.map((product) => (
              <IngredientRow
                key={product.name}
                product={product}
                productStock={product.units}
              />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

export const KitchenTop = (props, context) => {
  const { act, data } = useBackend(context);
  const { inactive,
          tooltip
        } = data;

  return (
    <Section title="Controls">
      <Flex>
        <Flex.Item width="50%" mr="3px">
          <Button
            fluid
            textAlign="center"
            icon="power-off"
            disabled={inactive}
            tooltip={tooltip}
            tooltipPosition="bottom"
            content="Activate"
            onClick={() => act('cook')}
          />
        </Flex.Item>
        <Flex.Item width="50%" mr="3px">
          <Button
            fluid
            textAlign="center"
            icon="eject"
            disabled={inactive}
            tooltip={inactive ? tooltip : ""}
            tooltipPosition="bottom"
            content="Eject Contents"
            onClick={() => act('eject')}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
}

export const Operating = (props, context) => {
  const { data } = useBackend(context);
  const { operating,
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

export const IngredientRow = (props, context) => {
  const { act, data } = useBackend(context);
  const { product } = props;
  return (
    <Table.Row>
      <Table.Cell bold>{product.name}</Table.Cell>
      <Table.Cell collapsing textAlign="center">
      {product.amount} {product.units}
      </Table.Cell>
    </Table.Row>
  );
};
