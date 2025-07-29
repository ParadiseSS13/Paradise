import { Button, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Operating } from './common/Operating';

export const KitchenMachine = (props) => {
  const { data, config } = useBackend();
  const { ingredients, operating } = data;
  const { title } = config;

  return (
    <Window width={400} height={320}>
      <Window.Content>
        <Stack fill vertical>
          <Operating operating={operating} name={title} />
          <Stack.Item>
            <KitchenTop />
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Ingredients">
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
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const KitchenTop = (props) => {
  const { act, data } = useBackend();
  const { inactive, tooltip } = data;

  return (
    <Section title="Controls">
      <Stack>
        <Stack.Item grow>
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
        </Stack.Item>
        <Stack.Item grow>
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
        </Stack.Item>
      </Stack>
    </Section>
  );
};
