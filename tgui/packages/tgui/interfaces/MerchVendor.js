import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Table, Tabs } from '../components';
import { Flex, FlexItem } from '../components/Flex';
import { Window } from '../layouts';

const VendingRow = (props, context) => {
  const { act, data } = useBackend(context);
  const { product, productImage, productCategory } = props;
  const { user_money } = data;

  return (
    <Table.Row>
      <Table.Cell collapsing>
        <img
          src={`data:image/jpeg;base64,${productImage}`}
          style={{
            'vertical-align': 'middle',
            width: '32px',
            margin: '0px',
            'margin-left': '0px',
          }}
        />
      </Table.Cell>
      <Table.Cell bold>{product.name}</Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Button
          disabled={product.price > user_money}
          icon="shopping-cart"
          content={product.price}
          textAlign="left"
          onClick={() =>
            act('purchase', {
              'name': product.name,
              'category': productCategory,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  );
};

const MerchProducts = (props, context) => {
  const { data } = useBackend(context);
  const [tabIndex] = useLocalState(context, 'tabIndex', 1);
  const { products, imagelist } = data;

  const categories = ['apparel', 'toy', 'decoration'];

  return (
    <Table>
      {products[categories[tabIndex]].map((product) => (
        <VendingRow
          key={product.name}
          product={product}
          productImage={imagelist[product.path]}
          productCategory={categories[tabIndex]}
        />
      ))}
    </Table>
  );
};

export const MerchVendor = (props, context) => {
  const { act, data } = useBackend(context);
  const { user_cash, inserted_cash } = data;

  return (
    <Window title="Merch Computer" resizable>
      <Window.Content scrollable>
        <Section title="User">
          <Box m={2}>
            Doing your job and not getting any recognition at work? Well,
            welcome to the merch shop! Here, you can buy cool things in exchange
            for money you earn when you have completed your Job Objectives.
          </Box>
          {user_cash !== null && (
            <Box>
              Your balance is <b>{user_cash ? user_cash : 0} credits</b>.
            </Box>
          )}
          <Flex>
            <FlexItem width="50%">
              <Box color="light-grey">
                There is <b>{inserted_cash}</b> credits inserted.
              </Box>
            </FlexItem>
            <FlexItem width="50%">
              <Button
                disabled={!inserted_cash}
                icon="money-bill-wave-alt"
                content="Dispense Change"
                textAlign="left"
                onClick={() => act('change')}
              />
            </FlexItem>
          </Flex>
        </Section>
        <Section title="Products">
          <MerchVendorNavigation />
          <MerchProducts />
        </Section>
      </Window.Content>
    </Window>
  );
};

const MerchVendorNavigation = (properties, context) => {
  const { data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 1);
  const { login_state } = data;

  return (
    <Tabs>
      <Tabs.Tab selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
        Toys
      </Tabs.Tab>
      <Tabs.Tab selected={2 === tabIndex} onClick={() => setTabIndex(2)}>
        Decorations
      </Tabs.Tab>
    </Tabs>
  );
};
