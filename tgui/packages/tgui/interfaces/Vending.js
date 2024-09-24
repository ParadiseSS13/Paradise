import { useBackend } from '../backend';
import { Box, Button, DmIcon, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

const VendingRow = (props, context) => {
  const { act, data } = useBackend(context);
  const { product, productStock, productIcon, productIconState } = props;
  const { chargesMoney, user, usermoney, inserted_cash, vend_ready, inserted_item_name } = data;
  const free = !chargesMoney || product.price === 0;
  let buttonText = 'ERROR!';
  let rowIcon = '';
  if (free) {
    buttonText = 'FREE';
    rowIcon = 'arrow-circle-down';
  } else {
    buttonText = product.price;
    rowIcon = 'shopping-cart';
  }
  let buttonDisabled =
    !vend_ready || productStock === 0 || (!free && product.price > usermoney && product.price > inserted_cash);
  return (
    <Table.Row>
      <Table.Cell collapsing>
        <DmIcon icon={productIcon} icon_state={productIconState} verticalAlign="middle" />
      </Table.Cell>
      <Table.Cell bold>{product.name}</Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Box color={(productStock <= 0 && 'bad') || (productStock <= product.max_amount / 2 && 'average') || 'good'}>
          {productStock} in stock
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Button
          fluid
          disabled={buttonDisabled}
          icon={rowIcon}
          content={buttonText}
          textAlign="left"
          onClick={() =>
            act('vend', {
              'inum': product.inum,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  );
};

export const Vending = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    user,
    usermoney,
    inserted_cash,
    chargesMoney,
    product_records = [],
    hidden_records = [],
    stock,
    vend_ready,
    inserted_item_name,
    panel_open,
    speaker,
  } = data;
  let inventory;

  inventory = [...product_records];
  if (data.extended_inventory) {
    inventory = [...inventory, ...hidden_records];
  }
  // Just in case we still have undefined values in the list
  inventory = inventory.filter((item) => !!item);
  return (
    <Window
      title="Vending Machine"
      width={450}
      height={Math.min((chargesMoney ? 171 : 89) + inventory.length * 32, 585)}
    >
      <Window.Content scrollable>
        <Stack fill vertical>
          {!!chargesMoney && (
            <Stack.Item>
              <Section
                title="User"
                buttons={
                  <Stack>
                    <Stack.Item>
                      {!!inserted_item_name && (
                        <Button
                          fluid
                          icon="eject"
                          content={<span style={{ 'text-transform': 'capitalize' }}>{inserted_item_name}</span>}
                          onClick={() => act('eject_item', {})}
                        />
                      )}
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        disabled={!inserted_cash}
                        icon="money-bill-wave-alt"
                        content={inserted_cash ? <>{<b>{inserted_cash}</b>} credits</> : 'Dispense Change'}
                        tooltip={inserted_cash ? 'Dispense Change' : null}
                        textAlign="left"
                        onClick={() => act('change')}
                      />
                    </Stack.Item>
                  </Stack>
                }
              >
                {user && (
                  <Box>
                    Welcome, <b>{user.name}</b>, <b>{user.job || 'Unemployed'}</b>!
                    <br />
                    Your balance is <b>{usermoney} credits</b>.
                    <br />
                  </Box>
                )}
              </Section>
            </Stack.Item>
          )}
          {!!panel_open && (
            <Stack.Item>
              <Section title="Maintenance">
                <Button
                  icon={speaker ? 'check' : 'volume-mute'}
                  selected={speaker}
                  content="Speaker"
                  textAlign="left"
                  onClick={() => act('toggle_voice', {})}
                />
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill scrollable title="Products">
              <Table>
                {inventory.map((product) => (
                  <VendingRow
                    key={product.name}
                    product={product}
                    productStock={stock[product.name]}
                    productIcon={product.icon}
                    productIconState={product.icon_state}
                  />
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
