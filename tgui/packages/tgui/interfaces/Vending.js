import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Table } from '../components';
import { Window } from '../layouts';

const VendingRow = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    product,
    productStock,
  } = props;
  const {
    onstation,
    user,
    userMoney,
    vend_ready,
    coin_name,
    inserted_item_name,
  } = data;
  const free = (
    !onstation
    || product.price === 0
  );
  let buttonText = "ERROR!";
  let rowIcon = "";
  if (product.req_coin) {
    buttonText = "COIN";
    rowIcon = "circle";
  } else if (free) {
    buttonText = "FREE";
    rowIcon = "arrow-circle-down";
  } else {
    buttonText = product.price;
    rowIcon = "shopping-cart";
  }
  let buttonDisabled = (
    !vend_ready
    || (!coin_name && product.req_coin)
    || productStock === 0
    || (!free && product.price > userMoney)
  );
  return (
    <Table.Row>
      <Table.Cell bold>
        {product.name}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Box
          color={(
            productStock <= 0 && 'bad'
            || productStock <= (product.max_amount / 2) && 'average'
            || 'good'
          )}>
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
          onClick={() => act('vend', {
            'inum': product.inum,
          })} />
      </Table.Cell>
    </Table.Row>
  );
};

export const Vending = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    user,
    guestNotice,
    userMoney,
    onstation,
    product_records = [],
    coin_records = [],
    hidden_records = [],
    stock,
    vend_ready,
    coin_name,
    inserted_item_name,
    panel_open,
    speaker,
  } = data;
  let inventory;

  inventory = [
    ...product_records,
    ...coin_records,
  ];
  if (data.extended_inventory) {
    inventory = [
      ...inventory,
      ...hidden_records,
    ];
  }
  // Just in case we still have undefined values in the list
  inventory = inventory.filter(item => !!item);
  return (
    <Window
      title="Vending Machine"
      resizable>
      <Window.Content scrollable>
        {!!onstation && (
          <Section title="User">
            {user && (
              <Box>
                Welcome, <b>{user.name}</b>,
                {' '}
                <b>{user.job || 'Unemployed'}</b>!
                <br />
                Your balance is <b>{userMoney} credits</b>.
              </Box>
            ) || (
              <Box color="light-grey">
                {guestNotice}
              </Box>
            )}
          </Section>
        )}
        {!!coin_name && (
          <Section
            title="Coin"
            buttons={(
              <Button
                fluid
                icon="eject"
                content="Remove Coin"
                onClick={() => act('remove_coin', {})} />
            )}>
            <Box>
              {coin_name}
            </Box>
          </Section>
        )}
        {!!inserted_item_name && (
          <Section
            title="Item"
            buttons={(
              <Button
                fluid
                icon="eject"
                content="Eject Item"
                onClick={() => act('eject_item', {})} />
            )}>
            <Box>
              {inserted_item_name}
            </Box>
          </Section>
        )}
        {!!panel_open && (
          <Section
            title="Maintenance"
            buttons={(
              <Button
                fluid
                icon={speaker ? "check" : "times"}
                selected={speaker}
                content="Speaker"
                onClick={() => act('toggle_voice', {})} />
            )} />
        )}
        <Section title="Products">
          <Table>
            {inventory.map(product => (
              <VendingRow
                key={product.name}
                product={product}
                productStock={stock[product.name]} />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
