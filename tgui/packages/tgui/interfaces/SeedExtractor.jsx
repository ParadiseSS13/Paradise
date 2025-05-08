import { useState } from 'react';
import { Button, Icon, Input, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

export const SeedExtractor = (properties) => {
  const { act, data } = useBackend();
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

const SeedList = (properties) => {
  const { act, data } = useBackend();
  const { icons, seeds, vend_amount } = data;
  const [searchText, setSearchText] = useState('searchText', '');
  const [vendAmount, setVendAmount] = useState('vendAmount', 1);
  const [sortId, _setSortId] = useState('sortId', 'name');
  const [sortOrder, _setSortOrder] = useState('sortOrder', true);
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
                          verticalAlign: 'middle',
                          width: '32px',
                          margin: '0px',
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

const SortButton = (properties) => {
  const [sortId, setSortId] = useState('name');
  const [sortOrder, setSortOrder] = useState(true);
  const { id, children } = properties;
  return (
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
  );
};

const SeedExtractorActions = (properties) => {
  const { act, data } = useBackend();
  const { vend_amount } = data;
  const [searchText, setSearchText] = useState('');
  const [vendAmount, setVendAmount] = useState(1);
  return (
    <Stack fill>
      <Stack.Item grow>
        <Input
          placeholder="Search by name, variant, potency:70+, production:3-, ..."
          fluid
          onChange={(value) => setSearchText(value)}
        />
      </Stack.Item>
      <Stack.Item>
        Vend amount:
        <Input placeholder="1" onChange={(value) => setVendAmount(Number(value) >= 1 ? Number(value) : 1)} />
      </Stack.Item>
    </Stack>
  );
};
