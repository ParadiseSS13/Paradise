import { createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon, Input, LabeledList, Section, Stack, Tabs, Table } from '../components';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';

export const SeedExtractor = (properties, context) => {
  const { act, data } = useBackend(context);
  const { loginState, currentPage } = data;

  return (
    <Window theme="hydroponics" width={800} height={400}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <SeedExtractorActions />
          </Stack.Item>
          <SeedList />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const seedFilter = (searchText) => {
  const eq = (actual, test) => actual === test;
  const ge = (actual, test) => actual >= test;
  const le = (actual, test) => actual <= test;
  let terms = searchText.split(' ');
  let filters = [];
  for (let term of terms) {
    let parts = term.split(':');
    if (parts.length === 0) {
      continue;
    }
    if (parts.length === 1) {
      filters.push((seed) =>
        (seed.name + ' (' + seed.variant + ')').toLocaleLowerCase().includes(parts[0].toLocaleLowerCase())
      );
      continue;
    }
    if (parts.length > 2) {
      return (seed) => false;
    }
    let searchVal;
    let cmp = eq;
    if (parts[1][parts[1].length - 1] === '-') {
      cmp = le;
      searchVal = Number(parts[1].substring(0, parts[1].length - 1));
    } else if (parts[1][parts[1].length - 1] === '+') {
      cmp = ge;
      searchVal = Number(parts[1].substring(0, parts[1].length - 1));
    } else {
      searchVal = Number(parts[1]);
    }
    if (isNaN(searchVal)) {
      return (seed) => false;
    }
    switch (parts[0].toLocaleLowerCase()) {
      case 'l':
      case 'life':
      case 'lifespan':
        filters.push((seed) => cmp(seed.lifespan, searchVal));
        break;
      case 'e':
      case 'end':
      case 'endurance':
        filters.push((seed) => cmp(seed.endurance, searchVal));
        break;
      case 'm':
      case 'mat':
      case 'maturation':
        filters.push((seed) => cmp(seed.maturation, searchVal));
        break;
      case 'pr':
      case 'prod':
      case 'production':
        filters.push((seed) => cmp(seed.production, searchVal));
        break;
      case 'y':
      case 'yield':
        filters.push((seed) => cmp(seed.yield, searchVal));
        break;
      case 'po':
      case 'pot':
      case 'potency':
        filters.push((seed) => cmp(seed.potency, searchVal));
        break;
      case 's':
      case 'stock':
      case 'c':
      case 'count':
      case 'a':
      case 'amount':
        filters.push((seed) => cmp(seed.amount, searchVal));
        break;
      default:
        return (seed) => false;
    }
  }
  return (seed) => {
    for (let filter of filters) {
      if (!filter(seed)) {
        return false;
      }
    }
    return true;
  };
};

const SeedList = (properties, context) => {
  const { act, data } = useBackend(context);
  const { icons, seeds, vend_amount } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [vendAmount, setVendAmount] = useLocalState(context, 'vendAmount', 1);
  const [sortId, _setSortId] = useLocalState(context, 'sortId', 'name');
  const [sortOrder, _setSortOrder] = useLocalState(context, 'sortOrder', true);
  return (
    <Stack.Item grow mt={0.5}>
      <Section fill scrollable>
        <Table className="SeedExtractor__list">
          <Table.Row bold>
            <SortButton id="name">Name</SortButton>
            <SortButton id="lifespan">Lifespan</SortButton>
            <SortButton id="endurance">Endurance</SortButton>
            <SortButton id="maturation">Maturation</SortButton>
            <SortButton id="production">Production</SortButton>
            <SortButton id="yield">Yield</SortButton>
            <SortButton id="potency">Potency</SortButton>
            <SortButton id="amount">Stock</SortButton>
          </Table.Row>
          {seeds.lenth === 0
            ? 'No seeds present.'
            : seeds
                .filter(seedFilter(searchText))
                .sort((a, b) => {
                  const i = sortOrder ? 1 : -1;
                  if (typeof a[sortId] === 'number') {
                    return (a[sortId] - b[sortId]) * i;
                  }
                  return a[sortId].localeCompare(b[sortId]) * i;
                })
                .map((seed) => (
                  <Table.Row
                    key={seed.id}
                    onClick={() =>
                      act('vend', {
                        seed_id: seed.id,
                        seed_variant: seed.variant,
                        vend_amount: vendAmount,
                      })
                    }
                  >
                    <Table.Cell>
                      <img
                        src={`data:image/jpeg;base64,${icons[seed.image]}`}
                        style={{
                          'vertical-align': 'middle',
                          width: '32px',
                          margin: '0px',
                          'margin-left': '0px',
                        }}
                      />
                      {seed.name}
                    </Table.Cell>
                    <Table.Cell>{seed.lifespan}</Table.Cell>
                    <Table.Cell>{seed.endurance}</Table.Cell>
                    <Table.Cell>{seed.maturation}</Table.Cell>
                    <Table.Cell>{seed.production}</Table.Cell>
                    <Table.Cell>{seed.yield}</Table.Cell>
                    <Table.Cell>{seed.potency}</Table.Cell>
                    <Table.Cell>{seed.amount}</Table.Cell>
                  </Table.Row>
                ))}
        </Table>
      </Section>
    </Stack.Item>
  );
};

const SortButton = (properties, context) => {
  const [sortId, setSortId] = useLocalState(context, 'sortId', 'name');
  const [sortOrder, setSortOrder] = useLocalState(context, 'sortOrder', true);
  const { id, children } = properties;
  return (
    <Stack.Item grow>
      <Table.Cell>
        <Button
          color={sortId !== id && 'transparent'}
          fluid
          onClick={() => {
            if (sortId === id) {
              setSortOrder(!sortOrder);
            } else {
              setSortId(id);
              setSortOrder(true);
            }
          }}
        >
          {children}
          {sortId === id && <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />}
        </Button>
      </Table.Cell>
    </Stack.Item>
  );
};

const SeedExtractorActions = (properties, context) => {
  const { act, data } = useBackend(context);
  const { vend_amount } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [vendAmount, setVendAmount] = useLocalState(context, 'vendAmount', 1);
  return (
    <Stack fill>
      <Stack.Item grow>
        <Input
          placeholder="Search by name, variant, potency:70+, production:3-, ..."
          fluid
          onInput={(e, value) => setSearchText(value)}
        />
      </Stack.Item>
      <Stack.Item>
        Vend amount:
        <Input placeholder="1" onInput={(e, value) => setVendAmount(Number(value) >= 1 ? Number(value) : 1)} />
      </Stack.Item>
    </Stack>
  );
};
