import { Box, Button, DmIcon, Icon, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const VendingRow = (props) => {
  const { act, data } = useBackend();
  const { product, productStock, productIcon, productIconState } = props;
  const { locked, bypass_lock, user, usermoney, inserted_cash, vend_ready, inserted_item_name } = data;
  let buttonText = 'ERROR!';
  let rowIcon = '';
  if (locked && bypass_lock) {
    buttonText = 'FREE (' + product.price + ')';
    rowIcon = 'arrow-circle-down';
  } else if (!locked || product.price === 0) {
    buttonText = 'FREE';
    rowIcon = 'arrow-circle-down';
  } else {
    buttonText = product.price;
    rowIcon = 'shopping-cart';
  }
  let buttonDisabled =
    !vend_ready ||
    productStock === 0 ||
    (locked && !bypass_lock && product.price > usermoney && product.price > inserted_cash);
  return (
    <Table.Row>
      <Table.Cell collapsing>
        <DmIcon
          verticalAlign="middle"
          icon={productIcon}
          icon_state={productIconState}
          fallback={<Icon p={0.66} name={'spinner'} size={2} spin />}
        />
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

export const Vending = (props) => {
  const { act, data } = useBackend();
  const {
    user,
    usermoney,
    inserted_cash,
    product_records = [],
    hidden_records = [],
    stock,
    vend_ready,
    inserted_item_name,
    panel_open,
    speaker,
    locked,
    bypass_lock,
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
      height={Math.min((!locked || !!bypass_lock ? 230 : 171) + inventory.length * 32, 585)}
    >
      <Window.Content scrollable>
        <Stack fill vertical>
          {(!locked || !!bypass_lock) && (
            <Stack.Item>
              <Section title="Configuration">
                <Stack>
                  <Stack.Item>
                    <Button icon="pen-to-square" content="Rename Vendor" onClick={() => act('rename', {})} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="pen-to-square"
                      content="Change Vendor Appearance"
                      onClick={() => act('change_appearance', {})}
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}
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
                        content={<span style={{ textTransform: 'capitalize' }}>{inserted_item_name}</span>}
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
