import { createSearch, decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Flex, Icon, Input, LabeledList, Section, Table, Tabs } from '../components';
import { FlexItem } from '../components/Flex';
import { Window } from "../layouts";
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import { TemporaryNotice } from './common/TemporaryNotice';

const statusStyles = {
  "*Execute*": "execute",
  "*Arrest*": "arrest",
  "Incarcerated": "incarcerated",
  "Parolled": "parolled",
  "Released": "released",
  "Demote": "demote",
  "Search": "search",
  "Monitor": "monitor",
};

const doEdit = (context, field) => {
  modalOpen(context, 'edit', {
    field: field.edit,
    value: field.value,
  });
};

export const SecurityRecords = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    loginState,
    currentPage,
  } = data;

  let body;
  if (!loginState.logged_in) {
    return (
      <Window theme="security" resizable>
        <Window.Content>
          <LoginScreen />
        </Window.Content>
      </Window>
    );
  } else {
    if (currentPage === 1) {
      body = <SecurityRecordsPageList />;
    } else if (currentPage === 2) {
      body = <SecurityRecordsPageMaintenance />;
    } else if (currentPage === 3) {
      body = <SecurityRecordsPageView />;
    }
  }

  return (
    <Window theme="security" resizable>
      <ComplexModal />
      <Window.Content scrollable className="Layout__content--flexColumn">
        <LoginInfo />
        <TemporaryNotice />
        <SecurityRecordsNavigation />
        <Section height="100%" flexGrow="1">
          {body}
        </Section>
      </Window.Content>
    </Window>
  );
};

const SecurityRecordsNavigation = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    currentPage,
    general,
  } = data;
  return (
    <Tabs>
      <Tabs.Tab
        selected={currentPage === 1}
        onClick={() => act('page', { page: 1 })}>
        <Icon name="list" />
        List Records
      </Tabs.Tab>
      <Tabs.Tab
        selected={currentPage === 2}
        onClick={() => act('page', { page: 2 })}>
        <Icon name="wrench" />
        Record Maintenance
      </Tabs.Tab>
      {(currentPage === 3 && general && !general.empty) && (
        <Tabs.Tab
          selected={currentPage === 3}>
          <Icon name="file" />
          Record: {general.fields[0].value}
        </Tabs.Tab>
      )}
    </Tabs>
  );
};

const SecurityRecordsPageList = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    records,
  } = data;
  const [searchText, setSearchText] = useLocalState(context, "searchText", "");
  const [sortId, _setSortId] = useLocalState(context, "sortId", "name");
  const [sortOrder, _setSortOrder] = useLocalState(context, "sortOrder", true);
  return (
    <Flex direction="column" height="100%">
      <SecurityRecordsActions />
      <Section flexGrow="1" mt="0.5rem">
        <Table className="SecurityRecords__list">
          <Table.Row bold>
            <SortButton id="name">Name</SortButton>
            <SortButton id="id">ID</SortButton>
            <SortButton id="rank">Assignment</SortButton>
            <SortButton id="fingerprint">Fingerprint</SortButton>
            <SortButton id="status">Criminal Status</SortButton>
          </Table.Row>
          {records
            .filter(createSearch(searchText, record => {
              return record.name + "|"
                      + record.id + "|"
                      + record.rank + "|"
                      + record.fingerprint + "|"
                      + record.status;
            }))
            .sort((a, b) => {
              const i = sortOrder ? 1 : -1;
              return a[sortId].localeCompare(b[sortId]) * i;
            })
            .map(record => (
              <Table.Row
                key={record.id}
                className={"SecurityRecords__listRow--"
                            + statusStyles[record.status]}
                onClick={() => act('view', {
                  uid_gen: record.uid_gen,
                  uid_sec: record.uid_sec,
                })}>
                <Table.Cell><Icon name="user" /> {record.name}</Table.Cell>
                <Table.Cell>{record.id}</Table.Cell>
                <Table.Cell>{record.rank}</Table.Cell>
                <Table.Cell>{record.fingerprint}</Table.Cell>
                <Table.Cell>{record.status}</Table.Cell>
              </Table.Row>
            ))}
        </Table>
      </Section>
    </Flex>
  );
};

const SortButton = (properties, context) => {
  const [sortId, setSortId] = useLocalState(context, "sortId", "name");
  const [sortOrder, setSortOrder] = useLocalState(context, "sortOrder", true);
  const {
    id,
    children,
  } = properties;
  return (
    <Table.Cell>
      <Button
        color={sortId !== id && "transparent"}
        width="100%"
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}>
        {children}
        {sortId === id && (
          <Icon
            name={sortOrder ? "sort-up" : "sort-down"}
            ml="0.25rem;"
          />
        )}
      </Button>
    </Table.Cell>
  );
};

const SecurityRecordsActions = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    isPrinting,
  } = data;
  const [searchText, setSearchText] = useLocalState(context, "searchText", "");
  return (
    <Flex>
      <FlexItem>
        <Button
          content="New Record"
          icon="plus"
          onClick={() => act('new_general')}
        />
        <Button
          disabled={isPrinting}
          icon={isPrinting ? 'spinner' : 'print'}
          iconSpin={!!isPrinting}
          content="Print Cell Log"
          ml="0.25rem"
          onClick={() => modalOpen(context, "print_cell_log")}
        />
      </FlexItem>
      <FlexItem grow="1" ml="0.5rem">
        <Input
          placeholder="Search by Name, ID, Assignment, Fingerprint, Status"
          width="100%"
          onInput={(e, value) => setSearchText(value)}
        />
      </FlexItem>
    </Flex>
  );
};

const SecurityRecordsPageMaintenance = (properties, context) => {
  const { act } = useBackend(context);
  return (
    <Box>
      <Button
        disabled
        icon="download"
        content="Backup to Disk"
        tooltip="This feature is not available."
        tooltipPosition="right"
      /><br />
      <Button
        disabled
        icon="upload"
        content="Upload from Disk"
        tooltip="This feature is not available."
        tooltipPosition="right"
        my="0.5rem"
      /><br />
      <Button.Confirm
        icon="trash"
        content="Delete All Security Records"
        onClick={() => act('delete_security_all')}
        mb="0.5rem"
      /><br />
      <Button.Confirm
        icon="trash"
        content="Delete All Cell Logs"
        onClick={() => act('delete_cell_logs')}
      />
    </Box>
  );
};

const SecurityRecordsPageView = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    isPrinting,
    general,
    security,
  } = data;
  if (!general || !general.fields) {
    return (
      <Box color="bad">
        General records lost!
      </Box>
    );
  }
  return (
    <Fragment>
      <Section
        title="General Data"
        level={2}
        mt="-6px"
        buttons={
          <Fragment>
            <Button
              disabled={isPrinting}
              icon={isPrinting ? 'spinner' : 'print'}
              iconSpin={!!isPrinting}
              content="Print Record"
              onClick={() => act('print_record')}
            />
            <Button.Confirm
              icon="trash"
              tooltip={"WARNING: This will also delete the Security "
              + "and Medical records associated to this crew member!"}
              tooltipPosition="bottom-left"
              content="Delete Record"
              onClick={() => act('delete_general')}
            />
          </Fragment>
        }>
        <SecurityRecordsViewGeneral />
      </Section>
      <Section
        title="Security Data"
        level={2}
        mt="-12px"
        buttons={
          <Button.Confirm
            icon="trash"
            disabled={security.empty}
            content="Delete Record"
            onClick={() => act('delete_security')}
          />
        }>
        <SecurityRecordsViewSecurity />
      </Section>
    </Fragment>
  );
};

const SecurityRecordsViewGeneral = (_properties, context) => {
  const { data } = useBackend(context);
  const {
    general,
  } = data;
  if (!general || !general.fields) {
    return (
      <Box color="bad">
        General records lost!
      </Box>
    );
  }
  return (
    <Fragment>
      <Box float="left">
        <LabeledList>
          {general.fields.map((field, i) => (
            <LabeledList.Item key={i} label={field.field}>
              {decodeHtmlEntities('' + field.value)}
              {!!field.edit && (
                <Button
                  icon="pen"
                  ml="0.5rem"
                  mb={field.line_break ? '1rem' : 'initial'}
                  onClick={() => doEdit(context, field)}
                />
              )}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Box>
      <Box position="absolute" right="0" textAlign="right">
        {!!general.has_photos && (
          general.photos.map((p, i) => (
            <Box
              key={i}
              display="inline-block"
              textAlign="center"
              color="label">
              <img
                src={p}
                style={{
                  width: '96px',
                  'margin-bottom': '0.5rem',
                  '-ms-interpolation-mode': 'nearest-neighbor',
                }}
              /><br />
              Photo #{i + 1}
            </Box>
          ))
        )}
      </Box>
    </Fragment>
  );
};

const SecurityRecordsViewSecurity = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    security,
  } = data;
  if (!security || !security.fields) {
    return (
      <Box color="bad">
        Security records lost!<br />
        <Button
          icon="pen"
          content="Create New Record"
          mt="0.5rem"
          onClick={() => act('new_security')}
        />
      </Box>
    );
  }
  return (
    <Fragment>
      <LabeledList>
        {security.fields.map((field, i) => (
          <LabeledList.Item
            key={i}
            label={field.field}>
            {decodeHtmlEntities(field.value)}
            {!!field.edit && (
              <Button
                icon="pen"
                ml="0.5rem"
                mb={field.line_break ? '1rem' : 'initial'}
                onClick={() => doEdit(context, field)}
              />
            )}
          </LabeledList.Item>
        ))}
      </LabeledList>
      <Section
        title="Comments/Log"
        level={2}
        buttons={
          <Button
            icon="comment"
            content="Add Entry"
            onClick={() => modalOpen(context, 'comment_add')}
          />
        }>
        {security.comments.length === 0 ? (
          <Box color="label">
            No comments found.
          </Box>
        ) : security.comments.map((comment, i) => (
          <Box key={i}>
            <Box color="label" display="inline">
              {comment.header || "Auto-generated"}
            </Box><br />
            {comment.text || comment}
            <Button
              icon="comment-slash"
              color="bad"
              ml="0.5rem"
              onClick={() => act('comment_delete', { id: i + 1 })}
            />
          </Box>
        ))}
      </Section>
    </Fragment>
  );
};
