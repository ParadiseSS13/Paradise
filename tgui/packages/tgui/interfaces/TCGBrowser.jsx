import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const ALL_SERIES = 'All series';

export const TCGBrowser = (props) => {
  const { act, data } = useBackend();
  const { cards, series } = data;
  const [search, setSearch] = useState('');
  const [selectedSeries, setSelectedSeries] = useState(ALL_SERIES);
  const [selected, setSelected] = useState(null);

  const lowerSearch = search.toLowerCase();
  const filtered = cards.filter(
    (card) =>
      (selectedSeries === ALL_SERIES || card.series === selectedSeries) &&
      (card.name.toLowerCase().includes(lowerSearch) ||
        card.id.toLowerCase().includes(lowerSearch) ||
        card.effect?.toLowerCase().includes(lowerSearch)),
  );
  const selectedCard = cards.find(
    (card) => selected && card.series === selected.series && card.id === selected.id,
  );

  return (
    <Window width={900} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow basis="60%">
            <Section
              fill
              scrollable
              title={`Cards (${filtered.length}/${cards.length})`}
              buttons={
                <Stack>
                  <Stack.Item>
                    <Dropdown
                      width="14rem"
                      selected={selectedSeries}
                      options={[ALL_SERIES, ...series]}
                      onSelected={setSelectedSeries}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Input
                      placeholder="Search name, id or effect"
                      width="14rem"
                      value={search}
                      onChange={setSearch}
                    />
                  </Stack.Item>
                </Stack>
              }
            >
              <Table>
                <Table.Row header>
                  <Table.Cell collapsing />
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell collapsing>Rarity</Table.Cell>
                  <Table.Cell collapsing>Type</Table.Cell>
                  <Table.Cell collapsing>ATK/DEF</Table.Cell>
                </Table.Row>
                {filtered.map((card) => (
                  <Table.Row
                    key={`${card.series}/${card.id}`}
                    className="candystripe"
                    onClick={() =>
                      setSelected({ series: card.series, id: card.id })
                    }
                    style={{ cursor: 'pointer' }}
                  >
                    <Table.Cell collapsing>
                      <CardImage card={card} width="32px" />
                    </Table.Cell>
                    <Table.Cell bold>{card.name}</Table.Cell>
                    <Table.Cell collapsing>{card.rarity}</Table.Cell>
                    <Table.Cell collapsing>
                      {card.cardsubtype || card.cardtype}
                    </Table.Cell>
                    <Table.Cell collapsing>
                      {card.cardtype === 'Unit'
                        ? `${card.attack}/${card.defense}`
                        : '-'}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack.Item>
          <Stack.Item grow basis="40%">
            <Section fill scrollable title="Card details">
              {selectedCard ? (
                <CardDetails card={selectedCard} act={act} />
              ) : (
                <Box color="label">Select a card to view its details.</Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CardImage = ({ card, width }) =>
  card.missing_icon ? (
    <Box color="bad" bold>
      ?
    </Box>
  ) : (
    <img
      src={`data:image/png;base64,${card.image}`}
      style={{ verticalAlign: 'middle', width, imageRendering: 'pixelated' }}
    />
  );

const CardDetails = ({ card, act }) => (
  <Stack vertical>
    <Stack.Item textAlign="center">
      <CardImage card={card} width="128px" />
    </Stack.Item>
    {!!card.missing_icon && (
      <Stack.Item>
        <NoticeBox danger>
          Missing icon state &quot;{card.icon_state}&quot;
        </NoticeBox>
      </Stack.Item>
    )}
    <Stack.Item>
      <Box bold fontSize="1.2rem">
        {card.name}
      </Box>
      <Box color="label">
        {card.series} / {card.id}
      </Box>
    </Stack.Item>
    <Stack.Item>
      <Box>
        {card.rarity} {card.cardsubtype || card.cardtype}
        {!!card.faction && ` - ${card.faction}`}
      </Box>
      {card.cardtype === 'Unit' && (
        <Box>
          Level {card.level} | ATK {card.attack} | DEF {card.defense}
        </Box>
      )}
    </Stack.Item>
    {!!card.desc && (
      <Stack.Item>
        <Box italic dangerouslySetInnerHTML={{ __html: card.desc }} />
      </Stack.Item>
    )}
    {!!card.effect && (
      <Stack.Item>
        <Box bold>Effect</Box>
        <Box dangerouslySetInnerHTML={{ __html: card.effect }} />
      </Stack.Item>
    )}
    {!!card.rules && (
      <Stack.Item>
        <Box bold>Rules</Box>
        <Box dangerouslySetInnerHTML={{ __html: card.rules }} />
      </Stack.Item>
    )}
    <Stack.Item>
      <Button
        icon="plus"
        onClick={() => act('spawn_card', { series: card.series, id: card.id })}
      >
        Spawn illegal copy
      </Button>
    </Stack.Item>
  </Stack>
);
