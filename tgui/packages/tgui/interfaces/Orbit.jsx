import { useState } from 'react';
import { Box, Button, Divider, Icon, Input, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const PATTERN_NUMBER = / \(([0-9]+)\)$/;

const searchFor = (searchText) =>
  createSearch(searchText, (thing) => thing.name + (thing.assigned_role !== null ? '|' + thing.assigned_role : ''));

const compareString = (a, b) => (a < b ? -1 : a > b);

const compareNumberedText = (a, b) => {
  const aName = a.name;
  const bName = b.name;

  if (!aName || !bName) {
    return 0;
  }

  // Check if aName and bName are the same except for a number at the end
  // e.g. Medibot (2) and Medibot (3)
  const aNumberMatch = aName.match(PATTERN_NUMBER);
  const bNumberMatch = bName.match(PATTERN_NUMBER);

  if (aNumberMatch && bNumberMatch && aName.replace(PATTERN_NUMBER, '') === bName.replace(PATTERN_NUMBER, '')) {
    const aNumber = parseInt(aNumberMatch[1], 10);
    const bNumber = parseInt(bNumberMatch[1], 10);

    return aNumber - bNumber;
  }

  return compareString(aName, bName);
};

const BasicSection = (props) => {
  const { searchText, source, title, color, sorted } = props;
  const things = source.filter(searchFor(searchText));
  if (sorted) {
    things.sort(compareNumberedText);
  }
  return (
    source.length > 0 && (
      <Section title={`${title} - (${source.length})`}>
        {things.map((thing) => (
          <OrbitedButton key={thing.name} thing={thing} color={color} />
        ))}
      </Section>
    )
  );
};

const OrbitedButton = (props) => {
  const { act } = useBackend();
  const { color, thing } = props;

  return (
    <Button
      color={color}
      tooltip={
        thing.assigned_role ? (
          <Stack>
            <Box as="img" mr="0.5em" className={classes(['job_icons16x16', thing.assigned_role_sprite])} />{' '}
            {thing.assigned_role}
          </Stack>
        ) : (
          ''
        )
      }
      tooltipPosition="bottom"
      onClick={() =>
        act('orbit', {
          ref: thing.ref,
        })
      }
    >
      {thing.name}
      {thing.orbiters && (
        <Box inline ml={1}>
          {'('}
          {thing.orbiters} <Icon name="eye" />
          {')'}
        </Box>
      )}
    </Button>
  );
};

export const Orbit = (props) => {
  const { act, data } = useBackend();
  const { alive, antagonists, highlights, response_teams, tourist, auto_observe, dead, ssd, ghosts, misc, npcs } = data;

  const [searchText, setSearchText] = useState('');

  const collatedAntagonists = {};
  for (const antagonist of antagonists) {
    if (collatedAntagonists[antagonist.antag] === undefined) {
      collatedAntagonists[antagonist.antag] = [];
    }
    collatedAntagonists[antagonist.antag].push(antagonist);
  }

  const sortedAntagonists = Object.entries(collatedAntagonists);
  sortedAntagonists.sort((a, b) => {
    return compareString(a[0], b[0]);
  });

  const orbitMostRelevant = (searchText) => {
    for (const source of [
      sortedAntagonists.map(([_, antags]) => antags),
      tourist,
      highlights,
      alive,
      ghosts,
      ssd,
      dead,
      npcs,
      misc,
    ]) {
      const member = source.filter(searchFor(searchText)).sort(compareNumberedText)[0];
      if (member !== undefined) {
        act('orbit', { ref: member.ref });
        break;
      }
    }
  };

  return (
    <Window width={700} height={500}>
      <Window.Content scrollable>
        <Section>
          <Stack>
            <Stack.Item>
              <Icon name="search" />
            </Stack.Item>
            <Stack.Item grow>
              <Input
                placeholder="Search..."
                autoFocus
                fluid
                value={searchText}
                onChange={(value) => setSearchText(value)}
                onEnter={(value) => orbitMostRelevant(value)}
              />
            </Stack.Item>
            <Stack.Item>
              <Divider vertical />
            </Stack.Item>
            <Stack.Item>
              <Button
                inline
                color="transparent"
                tooltip="Refresh"
                tooltipPosition="bottom-start"
                icon="sync-alt"
                onClick={() => act('refresh')}
              />
            </Stack.Item>
          </Stack>
        </Section>
        {antagonists.length > 0 && (
          <Section title="Antagonists">
            {sortedAntagonists.map(([name, antags]) => (
              <Section key={name} title={`${name} - (${antags.length})`} level={2}>
                {antags
                  .filter(searchFor(searchText))
                  .sort(compareNumberedText)
                  .map((antag) => (
                    <OrbitedButton key={antag.name} color="bad" thing={antag} />
                  ))}
              </Section>
            ))}
          </Section>
        )}
        {highlights.length > 0 && (
          <BasicSection title="Highlights" source={highlights} searchText={searchText} color={'teal'} />
        )}

        <BasicSection title="Response Teams" source={response_teams} searchText={searchText} color={'purple'} />

        <BasicSection title="Tourists" source={tourist} searchText={searchText} color={'violet'} />

        <BasicSection title="Alive" source={alive} searchText={searchText} color={'good'} />

        <BasicSection title="Ghosts" source={ghosts} searchText={searchText} color={'grey'} />

        <BasicSection title="SSD" source={ssd} searchText={searchText} color={'grey'} />

        <BasicSection title="Dead" source={dead} searchText={searchText} sorted={false} />

        <BasicSection title="NPCs" source={npcs} searchText={searchText} sorted={false} />

        <BasicSection title="Misc" source={misc} searchText={searchText} sorted={false} />
      </Window.Content>
    </Window>
  );
};
