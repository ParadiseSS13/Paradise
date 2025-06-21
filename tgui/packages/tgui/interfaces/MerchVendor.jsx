import { useContext } from 'react';
import { Box, Button, Section, Stack, Table, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import TabsContext from './common/TabsContext';

const VendingRow = (props) => {
  const { act, data } = useBackend();
  const { product, productImage, productCategory } = props;
  const { user_money } = data;

  return (
    <Table.Row>
      <Table.Cell collapsing>
        <img
          src={`data:image/jpeg;base64,${productImage}`}
          style={{
            verticalAlign: 'middle',
            width: '32px',
            margin: '0px',
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

const MerchProducts = (props) => {
  const { data } = useBackend();
  const { tabIndex } = useContext(TabsContext);
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

export const MerchVendor = (props) => {
  const { act, data } = useBackend();
  const { user_cash, inserted_cash } = data;

  return (
    <Window title="Merch Computer" width={450} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="User"
              buttons={
                <>
                  <Box color="light-grey" inline mr="0.5rem">
                    There is <b>{inserted_cash}</b> credits inserted.
                  </Box>
                  <Button
                    disabled={!inserted_cash}
                    icon="money-bill-wave-alt"
                    content="Dispense Change"
                    textAlign="left"
                    onClick={() => act('change')}
                  />
                </>
              }
            >
              <Stack.Item>
                Doing your job and not getting any recognition at work? Well, welcome to the merch shop! Here, you can
                buy cool things in exchange for money you earn when you have completed your Job Objectives.
                {user_cash !== null && (
                  <Box mt="0.5rem">
                    Your balance is <b>{user_cash ? user_cash : 0} credits</b>.
                  </Box>
                )}
              </Stack.Item>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Products">
              <TabsContext.Default tabIndex={1}>
                <MerchVendorNavigation />
                <MerchProducts />
              </TabsContext.Default>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MerchVendorNavigation = (properties) => {
  const { data } = useBackend();
  const { tabIndex, setTabIndex } = useContext(TabsContext);
  const { login_state } = data;

  return (
    <Tabs>
      <Tabs.Tab icon="dice" selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
        Toys
      </Tabs.Tab>
      <Tabs.Tab icon="flag" selected={2 === tabIndex} onClick={() => setTabIndex(2)}>
        Decorations
      </Tabs.Tab>
    </Tabs>
  );
};
