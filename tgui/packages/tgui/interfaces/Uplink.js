import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

const PickTab = (index) => {
  switch (index) {
    case 0:
      return <ItemsPage />;
    case 1:
      return <CartPage />;
    case 2:
      return <ExploitableInfoPage />;
    default:
      return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
  }
};

export const Uplink = (props, context) => {
  const { act, data } = useBackend(context);
  const { cart } = data;

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  return (
    <Window width={900} height={610} theme="syndicate">
      <ComplexModal />
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                key="PurchasePage"
                selected={tabIndex === 0}
                onClick={() => {
                  setTabIndex(0);
                  setSearchText('');
                }}
                icon="store"
              >
                View Market
              </Tabs.Tab>
              <Tabs.Tab
                key="Cart"
                selected={tabIndex === 1}
                onClick={() => {
                  setTabIndex(1);
                  setSearchText('');
                }}
                icon="shopping-cart"
              >
                View Shopping Cart{' '}
                {cart && cart.length ? '(' + cart.length + ')' : ''}
              </Tabs.Tab>
              <Tabs.Tab
                key="ExploitableInfo"
                selected={tabIndex === 2}
                onClick={() => {
                  setTabIndex(2);
                  setSearchText('');
                }}
                icon="user"
              >
                Exploitable Information
              </Tabs.Tab>
              <Tabs.Tab
                key="LockUplink"
                // This cant ever be selected. Its just a close button.
                onClick={() => act('lock')}
                icon="lock"
              >
                Lock Uplink
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{PickTab(tabIndex)}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemsPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { crystals, cats } = data;
  // Default to first
  const [uplinkItems, setUplinkItems] = useLocalState(
    context,
    'uplinkItems',
    cats[0].items
  );

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const SelectEquipment = (cat, searchText = '') => {
    const EquipmentSearch = createSearch(searchText, (item) => {
      let is_hijack = item.hijack_only === 1 ? '|' + 'hijack' : '';
      return item.name + '|' + item.desc + '|' + item.cost + 'tc' + is_hijack;
    });
    return flow([
      filter((item) => item?.name), // Make sure it has a name
      searchText && filter(EquipmentSearch), // Search for anything
      sortBy((item) => item?.name), // Sort by name
    ])(cat);
  };
  const handleSearch = (value) => {
    setSearchText(value);
    if (value === '') {
      return setUplinkItems(cats[0].items);
    }
    setUplinkItems(
      SelectEquipment(cats.map((category) => category.items).flat(), value)
    );
  };

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', 1);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title={'Current Balance: ' + crystals + 'TC'}
          buttons={
            <>
              <Button.Checkbox
                content="Show Descriptions"
                checked={showDesc}
                onClick={() => setShowDesc(!showDesc)}
              />
              <Button
                content="Random Item"
                icon="question"
                onClick={() => act('buyRandom')}
              />
              <Button
                content="Refund Currently Held Item"
                icon="undo"
                onClick={() => act('refund')}
              />
            </>
          }
        >
          <Input
            fluid
            placeholder="Search Equipment"
            onInput={(e, value) => {
              handleSearch(value);
            }}
            value={searchText}
          />
        </Section>
        <Stack fill>
          <Stack.Item>
            <Section fill>
              <Tabs vertical>
                {cats.map((c) => (
                  <Tabs.Tab
                    key={c}
                    selected={
                      searchText !== '' ? false : c.items === uplinkItems
                    }
                    onClick={() => {
                      setUplinkItems(c.items);
                      setSearchText('');
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
              {uplinkItems.map((i) => (
                <UplinkItem
                  i={i}
                  showDecription={showDesc}
                  key={decodeHtmlEntities(i.name)}
                />
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const CartPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { cart, crystals, cart_price } = data;

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', 0);

  return (
    <Stack fill vertical>
      <Section
        title={'Current Balance: ' + crystals + 'TC'}
        buttons={
          <>
            <Button.Checkbox
              content="Show Descriptions"
              checked={showDesc}
              onClick={() => setShowDesc(!showDesc)}
            />
            <Button
              content="Empty Cart"
              icon="trash"
              onClick={() => act('empty_cart')}
              disabled={!cart}
            />
            <Button
              content={'Purchase Cart (' + cart_price + 'TC)'}
              icon="shopping-cart"
              onClick={() => act('purchase_cart')}
              disabled={!cart || cart_price > crystals}
            />
          </>
        }
      >
        <Stack.Item grow>
          {cart ? (
            cart.map((i) => (
              <UplinkItem
                i={i}
                showDecription={showDesc}
                key={decodeHtmlEntities(i.name)}
                buttons={<CartButtons i={i} />}
              />
            ))
          ) : (
            <Box italic>Your Shopping Cart is empty!</Box>
          )}
        </Stack.Item>
      </Section>
      <Advert />
    </Stack>
  );
};
const Advert = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { cats, lucky_numbers } = data;

  return (
    <Section
      title="Suggested Purchases"
      buttons={
        <Button
          icon="dice"
          content="See more suggestions"
          onClick={() => act('shuffle_lucky_numbers')}
        />
      }
    >
      <Box display="flex" flexWrap="wrap">
        {lucky_numbers
          .map((number) => cats[number.cat].items[number.item])
          .filter((item) => item !== undefined && item !== null)
          .map((item, index) => (
            <Stack.Item key={index} p="0.5%" width="49%">
              <UplinkItem grow i={item} />
            </Stack.Item>
          ))}
      </Box>
    </Section>
  );
};

const UplinkItem = (props, context) => {
  const {
    i,
    showDecription = 1,
    buttons = <UplinkItemButtons i={i} />,
  } = props;

  return (
    <Section
      title={decodeHtmlEntities(i.name)}
      showBottom={showDecription}
      buttons={buttons}
    >
      {showDecription ? <Box italic>{decodeHtmlEntities(i.desc)}</Box> : null}
    </Section>
  );
};

const UplinkItemButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { i } = props;
  const { crystals } = data;

  return (
    <>
      <Button
        icon="shopping-cart"
        color={i.hijack_only === 1 && 'red'}
        tooltip="Add to cart."
        tooltipPosition="left"
        onClick={() =>
          act('add_to_cart', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      />
      <Button
        content={
          'Buy (' + i.cost + 'TC)' + (i.refundable ? ' [Refundable]' : '')
        }
        color={i.hijack_only === 1 && 'red'}
        // Yes I care this much about both of these being able to render at the same time
        tooltip={i.hijack_only === 1 && 'Hijack Agents Only!'}
        tooltipPosition="left"
        onClick={() =>
          act('buyItem', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      />
    </>
  );
};

const CartButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { i } = props;
  const { exploitable } = data;

  return (
    <Stack>
      <Button
        icon="times"
        content={'(' + i.cost * i.amount + 'TC)'}
        tooltip="Remove from cart."
        tooltipPosition="left"
        onClick={() =>
          act('remove_from_cart', {
            item: i.obj_path,
          })
        }
      />
      <Button
        icon="minus"
        tooltip={i.limit === 0 && 'Discount already redeemed!'}
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
        tooltipPosition="bottom-start"
        tooltip={i.limit === 0 && 'Discount already redeemed!'}
        onCommit={(e, value) =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: value,
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit && i.amount <= 0}
      />
      <Button
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

const ExploitableInfoPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { exploitable } = data;
  // Default to first
  const [selectedRecord, setSelectedRecord] = useLocalState(
    context,
    'selectedRecord',
    exploitable[0]
  );

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  // Search for peeps
  const SelectMembers = (people, searchText = '') => {
    const MemberSearch = createSearch(searchText, (member) => member.name);
    return flow([
      // Null member filter
      filter((member) => member?.name),
      // Optional search term
      searchText && filter(MemberSearch),
      // Slightly expensive, but way better than sorting in BYOND
      sortBy((member) => member.name),
    ])(people);
  };

  const crew = SelectMembers(exploitable, searchText);

  return (
    <Section title="Exploitable Records">
      <Stack>
        <Stack.Item basis={20}>
          <Input
            fluid
            mb={1}
            placeholder="Search Crew"
            onInput={(e, value) => setSearchText(value)}
          />
          <Tabs vertical>
            {crew.map((r) => (
              <Tabs.Tab
                key={r}
                selected={r === selectedRecord}
                onClick={() => setSelectedRecord(r)}
              >
                {r.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Item grow={1} basis={0}>
          <Section title={'Name: ' + selectedRecord.name}>
            <Box>Age: {selectedRecord.age}</Box>
            <Box>Fingerprint: {selectedRecord.fingerprint}</Box>
            <Box>Rank: {selectedRecord.rank}</Box>
            <Box>Sex: {selectedRecord.sex}</Box>
            <Box>Species: {selectedRecord.species}</Box>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
