import { flow } from 'common/fp';
import { Fragment } from 'inferno';
import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Box,
  AnimatedNumber,
  Section,
  Dropdown,
  Input,
  Table,
  Modal,
  Icon,
  Flex,
} from '../components';
import { Window } from '../layouts';
import { LabeledListItem } from '../components/LabeledList';
import { createSearch, toTitleCase } from 'common/string';
import { FlexItem } from '../components/Flex';

export const CargoConsole = (props, context) => {
  return (
    <Window>
      <Window.Content>
        <ContentsModal />
        <StatusPane />
        <PaymentPane />
        <CataloguePane />
        <DetailsPane />
      </Window.Content>
    </Window>
  );
};

const ContentsModal = (_properties, context) => {
  const [contentsModal, setContentsModal] = useLocalState(
    context,
    'contentsModal',
    null
  );

  const [contentsModalTitle, setContentsModalTitle] = useLocalState(
    context,
    'contentsModalTitle',
    null
  );
  if (contentsModal !== null && contentsModalTitle !== null) {
    return (
      <Modal
        maxWidth="75%"
        width={window.innerWidth + 'px'}
        maxHeight={window.innerHeight * 0.75 + 'px'}
        mx="auto"
      >
        <Box width="100%" bold>
          <h1>{contentsModalTitle} contents:</h1>
        </Box>
        <Box>
          {contentsModal.map((i) => (
            // This needs keying. I hate it.
            <Box key={i}>- {i}</Box>
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
  const { is_public, timeleft, moving, at_station } = data;

  // Shuttle status text
  let statusText;
  let shuttleButtonText;
  if (!moving && !at_station) {
    statusText = 'Docked off-station';
    shuttleButtonText = 'Call Shuttle';
  } else if (!moving && at_station) {
    statusText = 'Docked at the station';
    shuttleButtonText = 'Return Shuttle';
  } else if (moving) {
    // Yes I am this fussy that it goes plural
    shuttleButtonText = 'In Transit...';
    if (timeleft !== 1) {
      statusText = 'Shuttle is en route (ETA: ' + timeleft + ' minutes)';
    } else {
      statusText = 'Shuttle is en route (ETA: ' + timeleft + ' minute)';
    }
  }

  return (
    <Section title="Status">
      <LabeledList>
        <LabeledList.Item label="Shuttle Status">{statusText}</LabeledList.Item>
        {is_public === 0 && (
          <LabeledList.Item label="Controls">
            <Button
              content={shuttleButtonText}
              disabled={moving}
              onClick={() => act('moveShuttle')}
            />
            <Button
              content="View Central Command Messages"
              onClick={() => act('showMessages')}
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

const PaymentPane = (properties, context) => {
  const { act, data } = useBackend(context);
  const { accounts } = data;
  const [selectedAccount, setSelectedAccount] = useLocalState(context, 'selectedAccount');

  let accountMap = []
  accounts.map(account => (
    accountMap[account.name] = account.account_UID
  ))

  return (
    <Section title="Payment">
      <Dropdown
        mt={0.6}
        width="190px"
        options={accounts.map((account) => account.name)}
        selected={accounts.filter(account => account.account_UID === selectedAccount)[0]?.name}
        onSelected={(val) => setSelectedAccount(accountMap[val])} />
      {accounts.filter(account => account.account_UID === selectedAccount)
        .map(account => (
          <LabeledList key={account.account_UID}>
            <LabeledList.Item label="Account Name">{account.name}</LabeledList.Item>
            <LabeledList.Item label="Balance">{account.balance}</LabeledList.Item>
          </LabeledList>
      ))}
    </Section>
  );
};

const CataloguePane = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { categories, supply_packs } = data;

  const [category, setCategory] = useSharedState(
    context,
    'category',
    'Emergency'
  );

  const [searchText, setSearchText] = useSharedState(
    context,
    'search_text',
    ''
  );

  const [contentsModal, setContentsModal] = useLocalState(
    context,
    'contentsModal',
    null
  );

  const [contentsModalTitle, setContentsModalTitle] = useLocalState(
    context,
    'contentsModalTitle',
    null
  );

  const packSearch = createSearch(searchText, (crate) => crate.name);
  const [selectedAccount, setSelectedAccount] = useLocalState(context, 'selectedAccount');
  const cratesToShow = flow([
    filter(
      (pack) =>
        pack.cat ===
          categories.filter((c) => c.name === category)[0].category ||
        searchText
    ),
    searchText && filter(packSearch),
    sortBy((pack) => pack.name.toLowerCase()),
  ])(supply_packs);

  let titleText = 'Crate Catalogue';
  if (searchText) {
    titleText = "Results for '" + searchText + "':";
  } else if (category) {
    titleText = 'Browsing ' + category;
  }
  return (
    <Section
      title={titleText}
      buttons={
        <Dropdown
          width="190px"
          options={categories.map((r) => r.name)}
          selected={category}
          onSelected={(val) => setCategory(val)}
        />
      }
    >
      <Input
        fluid
        placeholder="Search for..."
        onInput={(e, v) => setSearchText(v)}
        mb={1}
      />
      <Box maxHeight={25} overflowY="auto" overflowX="hidden">
        <Table m="0.5rem">
          {cratesToShow.map((c) => (
            <Table.Row key={c.name}>
              <Table.Cell bold>
                {c.name} ({c.cost} Credits)
              </Table.Cell>
              <Table.Cell textAlign="right" pr={1}>
                <Button
                  content="Order 1"
                  icon="shopping-cart"
                  disabled={!selectedAccount}
                  onClick={() =>
                    act('order', {
                      crate: c.ref,
                      multiple: 0,
                      account: selectedAccount,
                    })
                  }
                />
                <Button
                  content="Order Multiple"
                  icon="cart-plus"
                  disabled={!selectedAccount}
                  onClick={() =>
                    act('order', {
                      crate: c.ref,
                      multiple: 1,
                      account: selectedAccount,
                    })
                  }
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

const GetRequestNotice = (_properties, context) => {
  const { request } = _properties;

  let head_color;
  let head_name;

  switch (request.department) {
    case "Engineering":
      head_name = 'CE';
      head_color = 'orange';
      break;
    case "Medical":
      head_name = 'CMO';
      head_color = 'teal';
      break;
    case "Science":
      head_name = 'RD';
      head_color = 'purple';
      break;
    case "Supply":
      head_name = 'CT'; // cargo tech
      head_color = 'brown';
      break;
    case "Service":
      head_name = 'HOP';
      head_color = 'olive';
      break;
    case "Security":
      head_name = 'HOS';
      head_color = 'red';
      break;
    case "Command":
      head_name = 'CAP';
      head_color = 'blue';
      break;
    case "Assistant":
      head_name = 'Any Head';
      head_color = 'grey';
      break;
  }

  return (
    <Flex>
      <FlexItem mr={1}>
        Approval Required:
      </FlexItem>
      {Boolean(request.req_cargo_approval) &&
        <FlexItem mr={1}>
          <Button
            color='brown'
            content='QM'
            icon='user-tie'
            tooltip="This Order requires approval from the QM still"
            />
        </FlexItem>
      }
      {Boolean(request.req_head_approval) &&
        <FlexItem>
          <Button
            color={head_color}
            content={head_name}
            disabled={request.req_cargo_approval}
            icon='user-tie'
            tooltip={request.req_cargo_approval
              ? `This Order first requires approval from the QM before the ${head_name} can approve it`
              : `This Order requires approval from the ${head_name} still`}
            />
        </FlexItem>
      }
    </Flex>
  );
};

const DetailsPane = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { requests, orders, shipments } = data;
  return (
    <Section title="Orders">
      <Box maxHeight={15} overflowY="auto" overflowX="hidden">
        <Box bold>Requests</Box>
        <Table m="0.5rem">
          {requests.map((r) => (
            <Table.Row key={r.ordernum} className="Cargo_RequestList">
              <Table.Cell mb={1}>
                <Box>
                  Order #{r.ordernum}: {r.supply_type} ({r.cost} credits) for <b>{r.orderedby}</b> with {r.department ? `The ${r.department} Department` : "Their Personal"} Account
                </Box>
                <Box italic>Reason: {r.comment}</Box>
                <GetRequestNotice request={r}/>
              </Table.Cell>
              <Table.Cell textAlign="right" pr={1}>
                <Button
                  content="Approve"
                  color="green"
                  disabled={!r.can_approve}
                  onClick={() =>
                    act('approve', {
                      ordernum: r.ordernum,
                    })
                  }
                />
                <Button
                  content="Deny"
                  color="red"
                  disabled={!r.can_deny}
                  onClick={() =>
                    act('deny', {
                      ordernum: r.ordernum,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
        <Box bold>Orders Awaiting Delivery</Box>
        <Table m="0.5rem">
          {orders.map((r) => (
            <Table.Row key={r.ordernum}>
              <Table.Cell>
                <Box>
                  - #{r.ordernum}: {r.supply_type} for <b>{r.orderedby}</b>
                </Box>
                <Box italic>Reason: {r.comment}</Box>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
        <Box bold>Order in Transit</Box>
        <Table m="0.5rem">
          {shipments.map((r) => (
            <Table.Row key={r.ordernum}>
              <Table.Cell>
                <Box>
                  - #{r.ordernum}: {r.supply_type} for <b>{r.orderedby}</b>
                </Box>
                <Box italic>Reason: {r.comment}</Box>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Box>
    </Section>
  );
};
