import { decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Icon, LabeledList, Section, Tabs } from '../components';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import { TemporaryNotice } from './common/TemporaryNotice';
import { RecordsTable } from './common/RecordsTable';

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

const doEdit = (context, field) => {
  modalOpen(context, 'edit', {
    field: field.edit,
    value: field.value,
  });
};

export const SecurityRecords = (properties, context) => {
  const { act, data } = useBackend(context);
  const { loginState, currentPage } = data;

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
  const { currentPage, general } = data;
  return (
    <Tabs>
      <Tabs.Tab
        selected={currentPage === 1}
        onClick={() => act('page', { page: 1 })}
      >
        <Icon name="list" />
        List Records
      </Tabs.Tab>
      {currentPage === 2 && general && !general.empty && (
        <Tabs.Tab selected={currentPage === 2}>
          <Icon name="file" />
          Record: {general.fields[0].value}
        </Tabs.Tab>
      )}
    </Tabs>
  );
};

const SecurityRecordsPageList = (props, context) => {
  const { act, data } = useBackend(context);
  const { isPrinting, records } = data;
  return (
    <RecordsTable
      columns={[
        {
          id: 'name',
          name: 'Name',
          datum: {
            children: (value) => (
              <>
                <Icon name="user" /> {value}
              </>
            ),
          },
        },
        { id: 'id', name: 'ID' },
        { id: 'rank', name: 'Assignment' },
        { id: 'fingerprint', name: 'Fingerprint' },
        { id: 'status', name: 'Criminal Status' },
      ]}
      data={records}
      datumID={(datum) => datum.id}
      leftButtons={
        <>
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
            onClick={() => modalOpen(context, 'print_cell_log')}
          />
        </>
      }
      searchPlaceholder="Search by Name, ID, Assignment, Fingerprint, Status"
      datumRowProps={(datum) => ({
        className: `SecurityRecords__listRow--${statusStyles[datum.status]}`,
        onClick: () =>
          act('view', {
            uid_gen: datum.uid_gen,
            uid_sec: datum.uid_sec,
          }),
      })}
    />
  );
};

const SecurityRecordsPageView = (properties, context) => {
  const { act, data } = useBackend(context);
  const { isPrinting, general, security } = data;
  if (!general || !general.fields) {
    return <Box color="bad">General records lost!</Box>;
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
              tooltip={
                'WARNING: This will also delete the Security ' +
                'and Medical records associated to this crew member!'
              }
              tooltipPosition="bottom-left"
              content="Delete Record"
              onClick={() => act('delete_general')}
            />
          </Fragment>
        }
      >
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
        }
      >
        <SecurityRecordsViewSecurity />
      </Section>
    </Fragment>
  );
};

const SecurityRecordsViewGeneral = (_properties, context) => {
  const { data } = useBackend(context);
  const { general } = data;
  if (!general || !general.fields) {
    return <Box color="bad">General records lost!</Box>;
  }
  return (
    <Fragment>
      <Box float="left">
        <LabeledList>
          {general.fields.map((field, i) => (
            <LabeledList.Item key={i} label={field.field} prewrap>
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
        {!!general.has_photos &&
          general.photos.map((p, i) => (
            <Box
              key={i}
              display="inline-block"
              textAlign="center"
              color="label"
            >
              <img
                src={p}
                style={{
                  width: '96px',
                  'margin-bottom': '0.5rem',
                  '-ms-interpolation-mode': 'nearest-neighbor',
                }}
              />
              <br />
              Photo #{i + 1}
            </Box>
          ))}
      </Box>
    </Fragment>
  );
};

const SecurityRecordsViewSecurity = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { security } = data;
  if (!security || !security.fields) {
    return (
      <Box color="bad">
        Security records lost!
        <br />
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
          <LabeledList.Item key={i} label={field.field} prewrap>
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
        }
      >
        {security.comments.length === 0 ? (
          <Box color="label">No comments found.</Box>
        ) : (
          security.comments.map((comment, i) => (
            <Box key={i} prewrap>
              <Box color="label" display="inline">
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
    </Fragment>
  );
};
