import { flow } from 'common/fp';
import { Fragment } from 'inferno';
import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState, useLocalState } from "../backend";
import { Button, LabeledList, Box, AnimatedNumber, Section, Dropdown, Input, Table, Modal } from "../components";
import { Window } from "../layouts";
import { LabeledListItem } from "../components/LabeledList";
import { createSearch, toTitleCase } from 'common/string';

export const CargoConsole = (props, context) => {
  return (
    <Window>
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
    is_public,
    points,
    timeleft,
    moving,
    at_station,
  } = data;


  // Shuttle status text
  let statusText;
  let shuttleButtonText;
  if (!moving && !at_station) {
    statusText = "Docked off-station";
    shuttleButtonText = "Call Shuttle";
  } else if (!moving && at_station) {
    statusText = "Docked at the station";
    shuttleButtonText = "Return Shuttle";
  } else if (moving) {
    // Yes I am this fussy that it goes plural
    shuttleButtonText = "In Transit...";
    if (timeleft !== 1) {
      statusText = "Shuttle is en route (ETA: " + timeleft + " minutes)";
    } else {
      statusText = "Shuttle is en route (ETA: " + timeleft + " minute)";
    }
  }

  return (
    <Section title="Status">
      <LabeledList>
        <LabeledList.Item label="Points Available">
          {points}
        </LabeledList.Item>
        <LabeledList.Item label="Shuttle Status">
          {statusText}
        </LabeledList.Item>
        {is_public === 0 && (
          <LabeledList.Item label="Controls">
            <Button
              content={shuttleButtonText}
              disabled={moving}
              onClick={() => act("moveShuttle")}
            />
            <Button
              content="View Central Command Messages"
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
                {c.name} ({c.cost} Points)
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
