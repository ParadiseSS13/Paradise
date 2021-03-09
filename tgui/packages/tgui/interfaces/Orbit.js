import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Divider, Flex, Icon, Input, Section } from '../components';
import { Window } from '../layouts';

const PATTERN_NUMBER = / \(([0-9]+)\)$/;

const searchFor = searchText => createSearch(searchText, thing => thing.name);

const compareString = (a, b) => a < b ? -1 : a > b;

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

  if (aNumberMatch
    && bNumberMatch
    && aName.replace(PATTERN_NUMBER, "") === bName.replace(PATTERN_NUMBER, "")
  ) {
    const aNumber = parseInt(aNumberMatch[1], 10);
    const bNumber = parseInt(bNumberMatch[1], 10);

    return aNumber - bNumber;
  }

  return compareString(aName, bName);
};

const BasicSection = (props, context) => {
  const { act } = useBackend(context);
  const { searchText, source, title } = props;
  const things = source.filter(searchFor(searchText));
  things.sort(compareNumberedText);
  return source.length > 0 && (
    <Section title={`${title} - (${source.length})`}>
      {things.map(thing => (
        <Button
          key={thing.name}
          content={thing.name}
          onClick={() => act("orbit", {
            ref: thing.ref,
          })} />
      ))}
    </Section>
  );
};

const OrbitedButton = (props, context) => {
  const { act } = useBackend(context);
  const { color, thing } = props;

  return (
    <Button
      color={color}
      onClick={() => act("orbit", {
        ref: thing.ref,
      })}>
      {thing.name}
    </Button>
  );
};

export const Orbit = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    alive,
    antagonists,
    auto_observe,
    dead,
    ghosts,
    misc,
    npcs,
  } = data;

  const [searchText, setSearchText] = useLocalState(context, "searchText", "");

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

  const orbitMostRelevant = searchText => {
    for (const source of [
      sortedAntagonists.map(([_, antags]) => antags),
      alive, ghosts, dead, npcs, misc,
    ]) {
      const member = source
        .filter(searchFor(searchText))
        .sort(compareNumberedText)[0];
      if (member !== undefined) {
        act("orbit", { ref: member.ref });
        break;
      }
    }
  };

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item>
              <Icon
                name="search"
                mr={1} />
            </Flex.Item>
            <Flex.Item grow={1}>
              <Input
                placeholder="Search..."
                autoFocus
                fluid
                value={searchText}
                onInput={(_, value) => setSearchText(value)}
                onEnter={(_, value) => orbitMostRelevant(value)} />
            </Flex.Item>
            <Flex.Item>
              <Divider vertical />
            </Flex.Item>
            <Flex.Item>
              <Button
                inline
                color="transparent"
                tooltip="Refresh"
                tooltipPosition="bottom-left"
                icon="sync-alt"
                onClick={() => act("refresh")} />
            </Flex.Item>
          </Flex>
        </Section>
        {antagonists.length > 0 && (
          <Section title="Antagonists">
            {sortedAntagonists.map(([name, antags]) => (
              <Section key={name} title={name} level={2}>
                {antags
                  .filter(searchFor(searchText))
                  .sort(compareNumberedText)
                  .map(antag => (
                    <OrbitedButton
                      key={antag.name}
                      color="bad"
                      thing={antag}
                    />
                  ))}
              </Section>
            ))}
          </Section>
        )}

        <Section title={`Alive - (${alive.length})`}>
          {alive
            .filter(searchFor(searchText))
            .sort(compareNumberedText)
            .map(thing => (
              <OrbitedButton
                key={thing.name}
                color="good"
                thing={thing} />
            ))}
        </Section>

        <Section title={`Ghosts - (${ghosts.length})`}>
          {ghosts
            .filter(searchFor(searchText))
            .sort(compareNumberedText)
            .map(thing => (
              <OrbitedButton
                key={thing.name}
                color="grey"
                thing={thing} />
            ))}
        </Section>

        <BasicSection
          title="Dead"
          source={dead}
          searchText={searchText}
        />

        <BasicSection
          title="NPCs"
          source={npcs}
          searchText={searchText}
        />

        <BasicSection
          title="Misc"
          source={misc}
          searchText={searchText}
        />
      </Window.Content>
    </Window>
  );
};
