import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Section, Stack, Tabs, LabeledList } from '../components';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

const PickTab = (index) => {
  switch (index) {
    case 0:
      return <ItemsPage />;
    case 1:
      return <CartPage />;
    default:
      return 'ОШИБКА, СООБЩИТЕ РАЗРАБОТЧИКУ';
  }
};

export const Shop = (props, context) => {
  const { act, data } = useBackend(context);
  const { cart } = data;

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);

  return (
    <Window width={900} height={600} theme="abductor">
      <ComplexModal />
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                key="PurchasePage"
                selected={tabIndex === 0}
                onClick={() => {
                  setTabIndex(0);
                }}
                icon="store"
              >
                Торговля
              </Tabs.Tab>
              <Tabs.Tab
                key="Cart"
                selected={tabIndex === 1}
                onClick={() => {
                  setTabIndex(1);
                }}
                icon="shopping-cart"
              >
                Корзина {cart && cart.length ? '(' + cart.length + ')' : ''}
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{PickTab(tabIndex)}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// ================== ITEMS PAGE ==================

const ItemsPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { cash, cats } = data;
  // Default to first
  const [shopItems, setShopItems] = useLocalState(context, 'shopItems', cats[0].items);

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', 1);

  return (
    <Stack fill vertical>
      <Stack vertical>
        <Stack.Item>
          <Section
            title={'Средства: ' + cash + 'к'}
            buttons={
              <Button.Checkbox content="Подробности" checked={showDesc} onClick={() => setShowDesc(!showDesc)} />
            }
          />
        </Stack.Item>
      </Stack>
      <Stack fill mt={0.3}>
        <Stack.Item width="30%">
          <Section fill scrollable>
            <Tabs vertical>
              {cats.map((c) => (
                <Tabs.Tab
                  key={c}
                  selected={c.items === shopItems}
                  onClick={() => {
                    setShopItems(c.items);
                  }}
                >
                  {c.cat}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section fill scrollable>
            <Stack vertical>
              {shopItems.map((i) => (
                <Stack.Item key={decodeHtmlEntities(i.name)} p={1} backgroundColor={'rgba(255, 0, 0, 0.1)'}>
                  <ShopItem i={i} showDecription={showDesc} key={decodeHtmlEntities(i.name)} />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};

const CartPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { cart, cash, cart_price } = data;

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', 0);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={'Средства: ' + cash + 'к'}
          buttons={
            <>
              <Button.Checkbox content="Подробности" checked={showDesc} onClick={() => setShowDesc(!showDesc)} />
              <Button content="Очистить" icon="trash" onClick={() => act('empty_cart')} disabled={!cart} />
              <Button
                content={'Оплатить (' + cart_price + 'к)'}
                icon="shopping-cart"
                onClick={() => act('purchase_cart')}
                disabled={!cart || cart_price > cash}
              />
            </>
          }
        >
          <Stack vertical>
            {cart ? (
              cart.map((i) => (
                <Stack.Item key={decodeHtmlEntities(i.name)} p={1} mr={1} backgroundColor={'rgba(255, 0, 0, 0.1)'}>
                  <ShopItem i={i} showDecription={showDesc} buttons={<CartButtons i={i} />} />
                </Stack.Item>
              ))
            ) : (
              <Box italic>Ваша корзина пуста!</Box>
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ShopItem = (props, context) => {
  const { i, showDecription = 1, buttons = <ShopItemButtons i={i} /> } = props;

  return (
    <Section title={decodeHtmlEntities(i.name)} showBottom={showDecription} buttons={buttons}>
      {showDecription ? <Box italic>{decodeHtmlEntities(i.desc)}</Box> : null}
      {showDecription ? <Box italic>{decodeHtmlEntities(i.content)}</Box> : null}
    </Section>
  );
};

const ShopItemButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { i } = props;
  const { cash } = data;

  return (
    <Button
      icon="shopping-cart"
      content={'Добавить в корзину (' + i.cost + ' Кикиридитов)'}
      color={i.limit !== -1 && 'red'}
      tooltip="Добавить товар в корзину, увеличив общее число данного товара. Цена товара меняется в зависимости от полученных ценностей в Расчичетчикике."
      tooltipPosition="left"
      onClick={() =>
        act('add_to_cart', {
          item: i.obj_path,
        })
      }
      disabled={i.cost > cash || (i.limit !== -1 && i.purchased >= i.limit) || i.is_time_available === false}
    />
  );
};

const CartButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { i } = props;

  return (
    <Stack>
      <Button
        icon="times"
        content={'(' + i.cost * i.amount + 'к)'}
        tooltip="Убрать из корзины."
        tooltipPosition="left"
        onClick={() =>
          act('remove_from_cart', {
            item: i.obj_path,
          })
        }
      />
      <Button
        icon="minus"
        ml="5px"
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: --i.amount, // one lower
          })
        }
        disabled={i.amount <= 0}
      />
      <Button.Input
        content={i.amount}
        width="45px"
        tooltipPosition="bottom-end"
        onCommit={(e, value) =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: value,
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit && i.amount <= 0}
      />
      <Button
        mb={0.3}
        icon="plus"
        tooltipPosition="bottom-start"
        tooltip={i.limit === 0 && 'Discount already redeemed!'}
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: ++i.amount, // one higher
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit}
      />
    </Stack>
  );
};

const ContentImages = (props, context) => {
  const { act, data } = useBackend(context);
  const { pack } = props;

  return (
    <Stack fill horizontal>
      <Stack.Item width="70%">
        {pack.content_images.map((i) => (
          <Stack.Item grow key={i.ref}>
            <img
              src={`data:image/jpeg;base64,${i}`}
              style={{
                'vertical-align': 'middle',
                width: '32px',
                margin: '0px',
                'margin-left': '0px',
              }}
            />
          </Stack.Item>
        ))}
      </Stack.Item>
    </Stack>
  );
};
