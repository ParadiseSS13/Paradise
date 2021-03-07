import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch, decodeHtmlEntities } from 'common/string';
import { Fragment } from "inferno";
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Flex, Input, Section, Tabs } from "../components";
import { FlexItem } from "../components/Flex";
import { Window } from "../layouts";
import { ComplexModal } from './common/ComplexModal';

const PickTab = index => {
  switch (index) {
    case 0:
      return <ItemsPage />;
    case 1:
      return <ExploitableInfoPage />;
    default:
      return "SOMETHING WENT VERY WRONG PLEASE AHELP";
  }
};

export const Uplink = (props, context) => {
  const { act, data } = useBackend(context);

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);

  return (
    <Window theme="syndicate">
      <ComplexModal />
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            key="PurchasePage"
            selected={tabIndex === 0}
            onClick={() => setTabIndex(0)}
            icon="shopping-cart">
            Purchase Equipment
          </Tabs.Tab>
          <Tabs.Tab
            key="ExploitableInfo"
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}
            icon="user">
            Exploitable Information
          </Tabs.Tab>
          <Tabs.Tab
            key="LockUplink"
            // This cant ever be selected. Its just a close button.
            onClick={() => act('lock')}
            icon="lock">
            Lock Uplink
          </Tabs.Tab>
        </Tabs>
        {PickTab(tabIndex)}
      </Window.Content>
    </Window>
  );
};

const ItemsPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    crystals,
    cats,
  } = data;
  // Default to first
  const [
    uplinkCat,
    setUplinkCat,
  ] = useLocalState(context, 'uplinkTab', cats[0]);
  return (
    <Section
      title={"Current Balance: " + crystals + "TC"}
      buttons={
        <Fragment>
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
        </Fragment>
      }>
      <Flex>
        <FlexItem>
          <Tabs vertical>
            {cats.map(c => (
              <Tabs.Tab
                key={c}
                selected={c === uplinkCat}
                onClick={() => setUplinkCat(c)}>
                {c.cat}
              </Tabs.Tab>
            ))}
          </Tabs>
        </FlexItem>
        <Flex.Item grow={1} basis={0}>
          {uplinkCat.items.map(i => (
            <Section
              key={decodeHtmlEntities(i.name)}
              title={decodeHtmlEntities(i.name)}
              buttons={
                <Button
                  content={"Buy (" + i.cost + "TC)" + (i.refundable ? " [Refundable]" : "")}
                  color={i.hijack_only === 1 && "red"}
                  // Yes I care this much about both of these being able to render at the same time
                  tooltip={(i.hijack_only === 1 && "Hijack Agents Only!")}
                  tooltipPosition="left"
                  onClick={() => act("buyItem", {
                    item: i.obj_path,
                  })}
                  disabled={i.cost > crystals}
                />
              }>
              <Box italic>
                {decodeHtmlEntities(i.desc)}
              </Box>
            </Section>
          ))}
        </Flex.Item>
      </Flex>
    </Section>
  );
};


const ExploitableInfoPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    exploitable,
  } = data;
  // Default to first
  const [
    selectedRecord,
    setSelectedRecord,
  ] = useLocalState(context, 'selectedRecord', exploitable[0]);

  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  // Search for peeps
  const SelectMembers = (people, searchText = '') => {
    const MemberSearch = createSearch(searchText, member => member.name);
    return flow([
      // Null member filter
      filter(member => member?.name),
      // Optional search term
      searchText && filter(MemberSearch),
      // Slightly expensive, but way better than sorting in BYOND
      sortBy(member => member.name),
    ])(people);
  };

  const crew = SelectMembers(exploitable, searchText);

  return (
    <Section title="Exploitable Records">
      <Flex>
        <FlexItem basis={20}>
          <Input
            fluid
            mb={1}
            placeholder="Search Crew"
            onInput={(e, value) => setSearchText(value)} />
          <Tabs vertical>
            {crew.map(r => (
              <Tabs.Tab
                key={r}
                selected={r === selectedRecord}
                onClick={() => setSelectedRecord(r)}>
                {r.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </FlexItem>
        <Flex.Item grow={1} basis={0}>
          <Section title={"Name: " + selectedRecord.name}>
            <Box>Age: {selectedRecord.age}</Box>
            <Box>Fingerprint: {selectedRecord.fingerprint}</Box>
            <Box>Rank: {selectedRecord.rank}</Box>
            <Box>Sex: {selectedRecord.sex}</Box>
            <Box>Species: {selectedRecord.species}</Box>
          </Section>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
