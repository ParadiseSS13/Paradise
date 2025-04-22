import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch, decodeHtmlEntities } from 'common/string';
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
    case 2:
      return <ExploitableInfoPage />;
    default:
      return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
  }
};

export const Uplink = (props) => {
  const { act, data } = useBackend();
  const { cart } = data;

  const [tabIndex, setTabIndex] = useLocalState('tabIndex', 0);
  const [searchText, setSearchText] = useLocalState('searchText', '');

  return (
    <Window width={900} height={600} theme="syndicate">
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
                View Shopping Cart {cart && cart.length ? '(' + cart.length + ')' : ''}
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

const ItemsPage = (_properties) => {
  const { act, data } = useBackend();
  const { crystals, cats } = data;
  // Default to first
  const [uplinkItems, setUplinkItems] = useLocalState('uplinkItems', cats[0].items);

  const [searchText, setSearchText] = useLocalState('searchText', '');
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
    setUplinkItems(SelectEquipment(cats.map((category) => category.items).flat(), value));
  };

  const [showDesc, setShowDesc] = useLocalState('showDesc', 1);

  return (
    <Stack fill vertical>
      <Stack vertical>
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
                <Button content="Random Item" icon="question" onClick={() => act('buyRandom')} />
                <Button content="Refund Currently Held Item" icon="undo" onClick={() => act('refund')} />
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
        </Stack.Item>
      </Stack>
      <Stack fill mt={0.3}>
        <Stack.Item width="30%">
          <Section fill scrollable>
            <Tabs vertical>
              {cats.map((c) => (
                <Tabs.Tab
                  key={c}
                  selected={searchText !== '' ? false : c.items === uplinkItems}
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
            <Stack vertical>
              {uplinkItems.map((i) => (
                <Stack.Item key={decodeHtmlEntities(i.name)} p={1} backgroundColor={'rgba(255, 0, 0, 0.1)'}>
                  <UplinkItem i={i} showDecription={showDesc} key={decodeHtmlEntities(i.name)} />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};

const CartPage = (_properties) => {
  const { act, data } = useBackend();
  const { cart, crystals, cart_price } = data;

  const [showDesc, setShowDesc] = useLocalState('showDesc', 0);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={'Current Balance: ' + crystals + 'TC'}
          buttons={
            <>
              <Button.Checkbox content="Show Descriptions" checked={showDesc} onClick={() => setShowDesc(!showDesc)} />
              <Button content="Empty Cart" icon="trash" onClick={() => act('empty_cart')} disabled={!cart} />
              <Button
                content={'Purchase Cart (' + cart_price + 'TC)'}
                icon="shopping-cart"
                onClick={() => act('purchase_cart')}
                disabled={!cart || cart_price > crystals}
              />
            </>
          }
        >
          <Stack vertical>
            {cart ? (
              cart.map((i) => (
                <Stack.Item key={decodeHtmlEntities(i.name)} p={1} mr={1} backgroundColor={'rgba(255, 0, 0, 0.1)'}>
                  <UplinkItem i={i} showDecription={showDesc} buttons={<CartButtons i={i} />} />
                </Stack.Item>
              ))
            ) : (
              <Box italic>Your Shopping Cart is empty!</Box>
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Advert />
    </Stack>
  );
};
const Advert = (_properties) => {
  const { act, data } = useBackend();
  const { cats, lucky_numbers } = data;

  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title="Suggested Purchases"
        buttons={<Button icon="dice" content="See more suggestions" onClick={() => act('shuffle_lucky_numbers')} />}
      >
        <Stack wrap>
          {lucky_numbers
            .map((number) => cats[number.cat].items[number.item])
            .filter((item) => item !== undefined && item !== null)
            .map((item, index) => (
              <Stack.Item key={index} p={1} mb={1} ml={1} width={34} backgroundColor={'rgba(255, 0, 0, 0.15)'}>
                <UplinkItem grow i={item} />
              </Stack.Item>
            ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const UplinkItem = (props) => {
  const { i, showDecription = 1, buttons = <UplinkItemButtons i={i} /> } = props;

  return (
    <Section title={decodeHtmlEntities(i.name)} showBottom={showDecription} buttons={buttons}>
      {showDecription ? <Box italic>{decodeHtmlEntities(i.desc)}</Box> : null}
    </Section>
  );
};

const UplinkItemButtons = (props) => {
  const { act, data } = useBackend();
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
        content={'Buy (' + i.cost + 'TC)' + (i.refundable ? ' [Refundable]' : '')}
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

const CartButtons = (props) => {
  const { act, data } = useBackend();
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
        tooltipPosition="bottom-end"
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

const ExploitableInfoPage = (_properties) => {
  const { act, data } = useBackend();
  const { exploitable, selected_record } = data;
  // Default to first

  const [searchText, setSearchText] = useLocalState('searchText', '');

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
    <Stack fill>
      <Stack.Item width="30%">
        <Section fill scrollable title="Exploitable Records">
          <Input fluid mb={1} placeholder="Search Crew" onInput={(e, value) => setSearchText(value)} />
          <Tabs vertical>
            {crew.map((r) => (
              <Tabs.Tab
                key={r}
                selected={r.name === selected_record.name}
                onClick={() => act('view_record', { uid_gen: r.uid_gen })}
              >
                {r.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={selected_record.name}>
          <Stack>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Age">{selected_record.age}</LabeledList.Item>
                <LabeledList.Item label="Fingerprint">{selected_record.fingerprint}</LabeledList.Item>
                <LabeledList.Item label="Rank">{selected_record.rank}</LabeledList.Item>
                <LabeledList.Item label="Sex">{selected_record.sex}</LabeledList.Item>
                <LabeledList.Item label="Species">{selected_record.species}</LabeledList.Item>
                <LabeledList.Item label="NT Relation">{selected_record.nt_relation}</LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            {!!selected_record.has_photos &&
              selected_record.photos.map((p, i) => (
                <Stack.Item key={i} inline textAlign="center" color="label" ml={0}>
                  <img
                    src={p}
                    style={{
                      width: '96px',
                      'margin-top': '1rem',
                      'margin-bottom': '0.5rem',
                      '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                      'image-rendering': 'pixelated',
                    }}
                  />
                  <br />
                  Photo #{i + 1}
                </Stack.Item>
              ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
