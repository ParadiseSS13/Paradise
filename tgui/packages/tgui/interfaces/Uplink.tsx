import { filter, sortBy } from 'common/collections';
import { useState } from 'react';
import { Box, Button, Input, LabeledList, Section, Stack, Tabs } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { createSearch, decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

type DatacoreRecord = {
  name: string;
  has_photos: BooleanLike;
  photos: string[];
  age: number;
  fingerprint: string;
  rank: string;
  sex: string;
  species: string;
  nt_relation: string;
};

type UplinkData = {
  cart: Cart;
  selected_record: DatacoreRecord;
  exploitable: Exploitable[];
};

type Cart = UplinkItem[];

type UplinkItem = {
  name: string;
  desc: string;
  cost: number;
  hijack_only: BooleanLike;
  obj_path: string;
  amount: number;
  limit: number;
  category: string;
};

type UplinkItemsPage = {
  crystals: number;
  cart: Cart;
  cart_price: number;
  cats: UplinkCategory[];
  exploitable: Exploitable[];
  lucky_numbers: LuckyNumber[];
};

type LuckyNumber = {
  cat: number;
  item: number;
};

type Exploitable = {
  name: string;
  uid_gen: string;
};

type UplinkCategory = {
  cat: string;
  items: UplinkItem[];
};

const PickTab = (index: number) => {
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
  const { act, data } = useBackend<UplinkData>();
  const { cart } = data;

  const [tabIndex, setTabIndex] = useState(0);

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
  const { act, data } = useBackend<UplinkItemsPage>();
  const { crystals, cats } = data;
  // Default to first
  const [uplinkItems, setUplinkItems] = useState(cats[0].items);

  const [searchText, setSearchText] = useState('');
  const SelectEquipment = (items: UplinkItem[], searchText = '') => {
    items = filter(items, (item) => !!item.name);
    if (searchText) {
      const matches = createSearch<UplinkItem>(searchText, (item) => {
        let key = `${item.name}|${item.desc}|${item.cost}tc`;
        if (item.hijack_only) {
          key += '|hijack';
        }
        return key;
      });
      items = filter(items, (item) => matches(item));
    }
    return sortBy(items, (item) => item.name);
  };
  const handleSearch = (value) => {
    setSearchText(value);
    if (value === '') {
      return setUplinkItems(cats[0].items);
    }
    setUplinkItems(SelectEquipment(cats.map((category: UplinkCategory) => category.items).flat(), value));
  };

  const [showDesc, setShowDesc] = useState<BooleanLike>(1);

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
              value={searchText}
              onChange={(value) => {
                handleSearch(value);
              }}
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
                  key={c.cat}
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
  const { act, data } = useBackend<UplinkItemsPage>();
  const { cart, crystals, cart_price } = data;

  const [showDesc, setShowDesc] = useState<BooleanLike>(0);

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
  const { act, data } = useBackend<UplinkItemsPage>();
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
              <Stack.Item key={index} p={1} mb={1} ml={1} width={34} backgroundColor={'rgba(255, 0, 0, 0.15)'} grow>
                <UplinkItem i={item} />
              </Stack.Item>
            ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

type UplinkItemProps = {
  i: number;
  showDecription: BooleanLike;
};

const UplinkItem = (props) => {
  const { i, showDecription = 1, buttons = <UplinkItemButtons i={i} /> } = props;

  return (
    <Section title={decodeHtmlEntities(i.name)} buttons={buttons}>
      {showDecription ? <Box italic>{decodeHtmlEntities(i.desc)}</Box> : null}
    </Section>
  );
};

const UplinkItemButtons = (props) => {
  const { act, data } = useBackend<UplinkItemsPage>();
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

type CartButtonProps = {
  i: UplinkItem;
};

const CartButtons = (props: CartButtonProps) => {
  const { act, data } = useBackend<UplinkData>();
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
        value={`${i.amount}`}
        width="45px"
        tooltipPosition="bottom-end"
        tooltip={i.limit === 0 && 'Discount already redeemed!'}
        onCommit={(value) =>
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
  const { act, data } = useBackend<UplinkData>();
  const { exploitable, selected_record } = data;
  // Default to first

  const [searchText, setSearchText] = useState('');

  // Search for peeps
  const SelectMembers = (people: Exploitable[], searchText = ''): Exploitable[] => {
    let members = filter(people, (member) => !!member.name);
    if (searchText) {
      const matches = createSearch<Exploitable>(searchText, (member) => member.name);
      members = filter(members, (member) => matches(member));
    }
    return sortBy(members, (member) => member.name);
  };

  const crew = SelectMembers(exploitable, searchText);
  return (
    <Stack fill>
      <Stack.Item width="30%">
        <Section fill scrollable title="Exploitable Records">
          <Input fluid mb={1} placeholder="Search Crew" onChange={(value) => setSearchText(value)} />
          <Tabs vertical>
            {crew &&
              crew.map((r: Exploitable) => (
                <Tabs.Tab
                  key={r.uid_gen}
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
                      marginTop: '1rem',
                      marginBottom: '0.5rem',
                      imageRendering: 'pixelated',
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
