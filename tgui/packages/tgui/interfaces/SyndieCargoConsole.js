import { flow } from 'common/fp';
import { Fragment } from 'inferno';
import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState, useLocalState } from "../backend";
import { Button, LabeledList, Box, AnimatedNumber, Section, Dropdown, Input, Table, Modal } from "../components";
import { Window } from "../layouts";
import { LabeledListItem } from "../components/LabeledList";
import { createSearch, toTitleCase } from 'common/string';

export const SyndieCargoConsole = (props, context) => {
  return (
    <Window theme="syndicate">
      <Window.Content>
        <ContentsModal />
        <StatusPane />
        <CataloguePane />
        <DetailsPane />
      </Window.Content>
    </Window>
  );
};

const ContentsModal = (_properties, context) => {
  const [
    contentsModal,
    setContentsModal,
  ] = useLocalState(context, 'contentsModal', null);

  const [
    contentsModalTitle,
    setContentsModalTitle,
  ] = useLocalState(context, 'contentsModalTitle', null);
  if ((contentsModal !== null) && (contentsModalTitle !== null)) {
    return (
      <Modal
        maxWidth="75%"
        width={(window.innerWidth) + "px"}
        maxHeight={(window.innerHeight * 0.75) + "px"}
        mx="auto">
        <Box width="100%" bold><h1>{contentsModalTitle} contents:</h1></Box>
        <Box>
          {contentsModal.map(i => (
            // This needs keying. I hate it.
            <Box key={i}>
              - {i}
            </Box>
          ))}
        </Box>
        <Box m={2}>
          <Button
            content="Close"
            onClick={() => {
              setContentsModal(null);
              setContentsModalTitle(null);
            }}
          />
        </Box>
      </Modal>
    );
  } else {
    return;
  }
};

const StatusPane = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    is_public = 0,
    cash,
    wait_time,
    is_cooldown,
    telepads_status,
    adminAddCash,
  } = data;


  // Shuttle status text
  let statusText = telepads_status;
  let dynamicTooltip ="";
  let block = 0;
  let teleportButtonText = "";
  if (telepads_status === "Pads not linked!") {
    block = 0;
    dynamicTooltip="Attempts to link telepads to the console.";
    teleportButtonText = "Link pads";
  } else if (!is_cooldown) {
    block = 0;
    dynamicTooltip="Teleports your crates to the market. A reminder, some of the crates are directly stolen from NT trading routes. That means they can be locked. We are NOT sorry for the inconvenience";
    teleportButtonText = "Teleport";
  } else if (is_cooldown) {
    teleportButtonText = "Cooldown...";
    dynamicTooltip="Pads are cooling off...";
    block = 1;
    if (wait_time !== 1) {
      statusText = "" + telepads_status + " (ETA: " + wait_time + " seconds)";
    } else {
      statusText = "" + telepads_status + " (ETA: " + wait_time + " second)";
    }
  }

  return (
    <Section title="Status">
      <LabeledList>
        {is_public === 0 &&(
          <LabeledList.Item label="Money Available">
            {cash}
            <Button
              tooltip="Withdraw money from the console"
              content="Withdraw"
              onClick={() => act("withdraw", cash)}
            />
            <Button
              content={adminAddCash}
              tooltip="Bless the players with da money!"
              onClick={() => act("add_money", cash)}
            />

          </LabeledList.Item>
        )}
        <LabeledList.Item label="Telepads Status">
          {statusText}
        </LabeledList.Item>
        {is_public === 0 && (
          <LabeledList.Item label="Controls">
            <Button
              content={teleportButtonText}
              tooltip={dynamicTooltip}
              disabled={block}
              onClick={() => act("teleport")}
            />
            <Button
              content="View Syndicate Black Market Log"
              onClick={() => act("showMessages")}
            />
          </LabeledList.Item>
        )}

      </LabeledList>
    </Section>
  );
};


const CataloguePane = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    categories,
    supply_packs,
  } = data;

  const [
    category,
    setCategory,
  ] = useSharedState(context, "category", "Emergency");

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, "search_text", "");

  const [
    contentsModal,
    setContentsModal,
  ] = useLocalState(context, 'contentsModal', null);

  const [
    contentsModalTitle,
    setContentsModalTitle,
  ] = useLocalState(context, 'contentsModalTitle', null);

  const packSearch = createSearch(searchText, crate => crate.name);

  const cratesToShow = flow([
    filter(pack => (pack.cat === categories.filter(
      c => c.name === category)[0].category || searchText)
    ), searchText && filter(packSearch),
    sortBy(pack => pack.name.toLowerCase()),
  ])(supply_packs);

  let titleText = "Crate Catalogue";
  if (searchText) {
    titleText = "Results for '" + searchText + "':";
  } else if (category) {
    titleText = "Browsing " + category;
  }
  return (
    <Section
      title={titleText}
      buttons={
        <Dropdown
          width="190px"
          options={categories.map(r => r.name)}
          selected={category}
          onSelected={val => setCategory(val)} />
      }>
      <Input
        fluid
        placeholder="Search for..."
        onInput={(e, v) => setSearchText(v)}
        mb={1} />
      <Box maxHeight={25} overflowY="auto" overflowX="hidden">
        <Table m="0.5rem">
          {cratesToShow.map(c => (
            <Table.Row key={c.name}>
              <Table.Cell bold>
                {c.name} ({c.cost} Credits)
              </Table.Cell>
              <Table.Cell textAlign="right" pr={1}>
                <Button
                  content="Order 1"
                  icon="shopping-cart"
                  onClick={() => act("order", {
                    crate: c.ref,
                    multiple: 0,
                  })}
                />
                <Button
                  content="Order Multiple"
                  icon="cart-plus"
                  onClick={() => act("order", {
                    crate: c.ref,
                    multiple: 1,
                  })}
                />
                <Button
                  content="View Contents"
                  icon="search"
                  onClick={() => {
                    setContentsModal(c.contents);
                    setContentsModalTitle(c.name);
                  }}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Box>
    </Section>
  );
};

const DetailsPane = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    requests,
    canapprove,
    orders,
  } = data;
  return (
    <Section title="Details">
      <Box maxHeight={15} overflowY="auto" overflowX="hidden">
        <Box bold>Requests</Box>
        <Table m="0.5rem">
          {requests.map(r => (
            <Table.Row key={r.ordernum}>
              <Table.Cell>
                <Box>
                  - #{r.ordernum}: {r.supply_type} for <b>{r.orderedby}</b>
                </Box>
                <Box italic>
                  Reason: {r.comment}
                </Box>
              </Table.Cell>
              <Table.Cell textAlign="right" pr={1}>
                <Button
                  content="Approve"
                  color="green"
                  disabled={!canapprove}
                  onClick={() => act("approve", {
                    ordernum: r.ordernum,
                  })}
                />
                <Button
                  content="Deny"
                  color="red"
                  onClick={() => act("deny", {
                    ordernum: r.ordernum,
                  })}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
        <Box bold>Confirmed Orders</Box>
        <Table m="0.5rem">
          {orders.map(r => (
            <Table.Row key={r.ordernum}>
              <Table.Cell>
                <Box>
                  - #{r.ordernum}: {r.supply_type} for <b>{r.orderedby}</b>
                </Box>
                <Box italic>
                  Reason: {r.comment}
                </Box>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Box>
    </Section>
  );
};

