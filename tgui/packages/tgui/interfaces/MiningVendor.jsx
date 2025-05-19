import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  ImageButton,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const sortTypes = {
  'Alphabetical': (a, b) => a - b,
  'Availability': (a, b) => -(a.affordable - b.affordable),
  'Price': (a, b) => a.price - b.price,
};

export const MiningVendor = (_properties) => {
  const [gridLayout, setGridLayout] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [sortOrder, setSortOrder] = useState('Alphabetical');
  const [descending, setDescending] = useState(false);
  return (
    <Window width={400} height={525}>
      <Window.Content>
        <Stack fill vertical>
          <MiningVendorUser />
          <MiningVendorSearch
            gridLayout={gridLayout}
            setGridLayout={setGridLayout}
            setSearchText={setSearchText}
            sortOrder={sortOrder}
            setSortOrder={setSortOrder}
            descending={descending}
            setDescending={setDescending}
          />
          <MiningVendorItems
            gridLayout={gridLayout}
            searchText={searchText}
            sortOrder={sortOrder}
            descending={descending}
          />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MiningVendorUser = (_properties) => {
  const { act, data } = useBackend();
  const { has_id, id } = data;
  return (
    <NoticeBox success={has_id}>
      {has_id ? (
        <>
          <Box
            inline
            verticalAlign="middle"
            style={{
              float: 'left',
            }}
          >
            Logged in as {id.name}.<br />
            You have {id.points.toLocaleString('en-US')} points.
          </Box>
          <Button
            icon="eject"
            content="Eject ID"
            style={{
              float: 'right',
            }}
            onClick={() => act('logoff')}
          />
          <Box
            style={{
              clear: 'both',
            }}
          />
        </>
      ) : (
        'Please insert an ID in order to make purchases.'
      )}
    </NoticeBox>
  );
};

const MiningVendorItems = (props) => {
  const { act, data } = useBackend();
  const { has_id, id, items } = data;
  const { gridLayout } = props;
  // Search thingies
  const { searchText } = props;
  const { sortOrder, descending } = props;
  const searcher = createSearch(searchText, (item) => {
    return item[0];
  });

  let has_contents = false;
  let contents = Object.entries(items).map((kv, _i) => {
    let items_in_cat = Object.entries(kv[1])
      .filter(searcher)
      .map((kv2) => {
        kv2[1].affordable = has_id && id.points >= kv2[1].price;
        return kv2[1];
      })
      .sort(sortTypes[sortOrder]);
    if (items_in_cat.length === 0) {
      return;
    }
    if (descending) {
      items_in_cat = items_in_cat.reverse();
    }

    has_contents = true;
    return <MiningVendorItemsCategory key={kv[0]} title={kv[0]} items={items_in_cat} gridLayout={gridLayout} />;
  });
  return (
    <Stack.Item grow mt={0.5}>
      <Section fill scrollable>
        {has_contents ? contents : <Box color="label">No items matching your criteria was found!</Box>}
      </Section>
    </Stack.Item>
  );
};

const MiningVendorSearch = (props) => {
  const { gridLayout, setGridLayout, setSearchText, sortOrder, setSortOrder, descending, setDescending } = props;
  return (
    <Box>
      <Stack fill>
        <Stack.Item grow>
          <Input fluid mt={0.2} placeholder="Search by item name.." onChange={(value) => setSearchText(value)} />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={gridLayout ? 'list' : 'table-cells-large'}
            height={1.75}
            tooltip={gridLayout ? 'Toggle List Layout' : 'Toggle Grid Layout'}
            tooltipPosition="bottom-start"
            onClick={() => setGridLayout(!gridLayout)}
          />
        </Stack.Item>
        <Stack.Item basis="30%">
          <Dropdown
            selected={sortOrder}
            options={Object.keys(sortTypes)}
            width="100%"
            onSelected={(v) => setSortOrder(v)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={descending ? 'arrow-down' : 'arrow-up'}
            height={1.75}
            tooltip={descending ? 'Descending order' : 'Ascending order'}
            tooltipPosition="bottom-start"
            onClick={() => setDescending(!descending)}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const MiningVendorItemsCategory = (properties) => {
  const { act, data } = useBackend();
  const { title, items, gridLayout, ...rest } = properties;
  return (
    <Collapsible open title={title} {...rest}>
      {items.map((item) =>
        gridLayout ? (
          <ImageButton
            key={item.name}
            mb={0.5}
            imageSize={57.5}
            dmIcon={item.icon}
            dmIconState={item.icon_state}
            disabled={!data.has_id || data.id.points < item.price}
            tooltip={item.name}
            tooltipPosition="top"
            onClick={() =>
              act('purchase', {
                cat: title,
                name: item.name,
              })
            }
          >
            {item.price.toLocaleString('en-US')}
          </ImageButton>
        ) : (
          <ImageButton
            key={item.name}
            fluid
            mb={0.5}
            imageSize={32}
            dmIcon={item.icon}
            dmIconState={item.icon_state}
            buttons={
              <Button
                width={3.75}
                disabled={!data.has_id || data.id.points < item.price}
                onClick={() =>
                  act('purchase', {
                    cat: title,
                    name: item.name,
                  })
                }
              >
                {item.price.toLocaleString('en-US')}
              </Button>
            }
          >
            <Box textAlign={'left'}>{item.name}</Box>
          </ImageButton>
        )
      )}
    </Collapsible>
  );
};
