import { useContext, useState } from 'react';
import { Box, Button, Icon, Input, LabeledList, Section, Stack, Table, Tabs } from 'tgui-core/components';
import { createSearch, decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import SortableTableContext from './common/SortableTableContext';
import { TemporaryNotice } from './common/TemporaryNotice';

const statusStyles = {
  '*Execute*': 'execute',
  '*Arrest*': 'arrest',
  'Incarcerated': 'incarcerated',
  'Parolled': 'parolled',
  'Released': 'released',
  'Demote': 'demote',
  'Search': 'search',
  'Monitor': 'monitor',
};

const doEdit = (field) => {
  modalOpen('edit', {
    field: field.edit,
    value: field.value,
  });
};

export const SecurityRecords = (properties) => {
  const { act, data } = useBackend();
  const { loginState, currentPage } = data;

  let body;
  if (!loginState.logged_in) {
    return (
      <Window theme="security" width={800} height={900}>
        <Window.Content>
          <LoginScreen />
        </Window.Content>
      </Window>
    );
  } else {
    if (currentPage === 1) {
      body = <SecurityRecordsPageList />;
    } else if (currentPage === 2) {
      body = <SecurityRecordsPageView />;
    }
  }

  return (
    <Window theme="security" width={800} height={900}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <LoginInfo />
          <TemporaryNotice />
          <SecurityRecordsNavigation />
          {body}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SecurityRecordsNavigation = (properties) => {
  const { act, data } = useBackend();
  const { currentPage, general } = data;
  return (
    <Stack.Item m={0}>
      <Tabs>
        <Tabs.Tab icon="list" selected={currentPage === 1} onClick={() => act('page', { page: 1 })}>
          List Records
        </Tabs.Tab>
        {currentPage === 2 && general && !general.empty && (
          <Tabs.Tab icon="file" selected={currentPage === 2}>
            Record: {general.fields[0].value}
          </Tabs.Tab>
        )}
      </Tabs>
    </Stack.Item>
  );
};

const SecurityRecordsPageList = (properties) => {
  const [searchText, setSearchText] = useState('');
  return (
    <>
      <Stack.Item>
        <SecurityRecordsActions setSearchText={setSearchText} />
      </Stack.Item>
      <Stack.Item grow mt={0.5}>
        <Section fill scrollable>
          <SortableTableContext.Default sortId="name">
            <SecurityRecordsTable searchText={searchText} />
          </SortableTableContext.Default>
        </Section>
      </Stack.Item>
    </>
  );
};

const SecurityRecordsTable = (props) => {
  const { act, data } = useBackend();
  const { records } = data;
  const { searchText } = props;
  const { sortId, sortOrder } = useContext(SortableTableContext);
  return (
    <Table className="SecurityRecords__list">
      <Table.Row bold>
        <SortButton id="name">Name</SortButton>
        <SortButton id="id">ID</SortButton>
        <SortButton id="rank">Assignment</SortButton>
        <SortButton id="fingerprint">Fingerprint</SortButton>
        <SortButton id="status">Criminal Status</SortButton>
      </Table.Row>
      {records
        .filter(
          createSearch(searchText, (record) => {
            return record.name + '|' + record.id + '|' + record.rank + '|' + record.fingerprint + '|' + record.status;
          })
        )
        .sort((a, b) => {
          const i = sortOrder ? 1 : -1;
          return a[sortId].localeCompare(b[sortId]) * i;
        })
        .map((record) => (
          <Table.Row
            key={record.id}
            className={'SecurityRecords__listRow--' + statusStyles[record.status]}
            onClick={() =>
              act('view', {
                uid_gen: record.uid_gen,
                uid_sec: record.uid_sec,
              })
            }
          >
            <Table.Cell>
              <Icon name="user" /> {record.name}
            </Table.Cell>
            <Table.Cell>{record.id}</Table.Cell>
            <Table.Cell>{record.rank}</Table.Cell>
            <Table.Cell>{record.fingerprint}</Table.Cell>
            <Table.Cell>{record.status}</Table.Cell>
          </Table.Row>
        ))}
    </Table>
  );
};

const SortButton = (properties) => {
  const { sortId, setSortId, sortOrder, setSortOrder } = useContext(SortableTableContext);
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

const SecurityRecordsActions = (properties) => {
  const { act, data } = useBackend();
  const { isPrinting } = data;
  const { setSearchText } = properties;
  return (
    <Stack fill>
      <Stack.Item>
        <Button ml="0.25rem" content="New Record" icon="plus" onClick={() => act('new_general')} />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={isPrinting}
          icon={isPrinting ? 'spinner' : 'print'}
          iconSpin={!!isPrinting}
          content="Print Cell Log"
          onClick={() => modalOpen('print_cell_log')}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Input
          fluid
          placeholder="Search by Name, ID, Assignment, Fingerprint, Status"
          onChange={(value) => setSearchText(value)}
        />
      </Stack.Item>
    </Stack>
  );
};

const SecurityRecordsPageView = (properties) => {
  const { act, data } = useBackend();
  const { isPrinting, general, security } = data;
  if (!general || !general.fields) {
    return <Box color="bad">General records lost!</Box>;
  }
  return (
    <>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="General Data"
          buttons={
            <>
              <Button
                disabled={isPrinting}
                icon={isPrinting ? 'spinner' : 'print'}
                iconSpin={!!isPrinting}
                content="Print Record"
                onClick={() => act('print_record')}
              />
              <Button.Confirm
                icon="trash"
                tooltip={
                  'WARNING: This will also delete the Security ' +
                  'and Medical records associated with this crew member!'
                }
                tooltipPosition="bottom-start"
                content="Delete Record"
                onClick={() => act('delete_general')}
              />
            </>
          }
        >
          <SecurityRecordsViewGeneral />
        </Section>
      </Stack.Item>
      {!security || !security.fields ? (
        <Stack.Item grow color="bad">
          <Section
            fill
            title="Security Data"
            buttons={<Button icon="pen" content="Create New Record" onClick={() => act('new_security')} />}
          >
            <Stack fill>
              <Stack.Item bold grow textAlign="center" fontSize={1.75} align="center" color="label">
                <Icon.Stack>
                  <Icon name="scroll" size={5} color="gray" />
                  <Icon name="slash" size={5} color="red" />
                </Icon.Stack>
                <br />
                Security records lost!
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      ) : (
        <>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Security Data"
              buttons={
                <Button.Confirm
                  icon="trash"
                  disabled={security.empty}
                  content="Delete Record"
                  onClick={() => act('delete_security')}
                />
              }
            >
              <Stack.Item>
                <LabeledList>
                  {security.fields.map((field, i) => (
                    <LabeledList.Item key={i} label={field.field} preserveWhitespace>
                      {decodeHtmlEntities(field.value)}
                      {!!field.edit && (
                        <Button
                          icon="pen"
                          ml="0.5rem"
                          mb={field.line_break ? '1rem' : 'initial'}
                          onClick={() => doEdit(field)}
                        />
                      )}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              </Stack.Item>
            </Section>
          </Stack.Item>
          <SecurityRecordsViewSecurity />
        </>
      )}
    </>
  );
};

const SecurityRecordsViewGeneral = (_properties) => {
  const { data } = useBackend();
  const { general } = data;
  if (!general || !general.fields) {
    return (
      <Stack fill vertical>
        <Stack.Item grow color="bad">
          <Section fill>General records lost!</Section>
        </Stack.Item>
      </Stack>
    );
  }
  return (
    <Stack>
      <Stack.Item grow>
        <LabeledList>
          {general.fields.map((field, i) => (
            <LabeledList.Item key={i} label={field.field} preserveWhitespace>
              {decodeHtmlEntities('' + field.value)}
              {!!field.edit && (
                <Button
                  icon="pen"
                  ml="0.5rem"
                  mb={field.line_break ? '1rem' : 'initial'}
                  onClick={() => doEdit(field)}
                />
              )}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Stack.Item>
      {!!general.has_photos &&
        general.photos.map((p, i) => (
          <Stack.Item key={i} inline textAlign="center" color="label" ml={0}>
            <img
              src={p}
              style={{
                width: '96px',
                marginTop: '5rem',
                marginBottom: '0.5rem',
                imageRendering: 'pixelated',
              }}
            />
            <br />
            Photo #{i + 1}
          </Stack.Item>
        ))}
    </Stack>
  );
};

const SecurityRecordsViewSecurity = (_properties) => {
  const { act, data } = useBackend();
  const { security } = data;
  return (
    <Stack.Item height="150px">
      <Section
        fill
        scrollable
        title="Comments/Log"
        buttons={<Button icon="comment" content="Add Entry" onClick={() => modalOpen('comment_add')} />}
      >
        {security.comments.length === 0 ? (
          <Box color="label">No comments found.</Box>
        ) : (
          security.comments.map((comment, i) => (
            <Box key={i} preserveWhitespace>
              <Box color="label" inline>
                {comment.header || 'Auto-generated'}
              </Box>
              <br />
              {comment.text || comment}
              <Button
                icon="comment-slash"
                color="bad"
                ml="0.5rem"
                onClick={() => act('comment_delete', { id: i + 1 })}
              />
            </Box>
          ))
        )}
      </Section>
    </Stack.Item>
  );
};
