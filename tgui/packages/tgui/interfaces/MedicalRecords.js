import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
  Tabs,
  Flex,
  Table,
} from '../components';
import {
  ComplexModal,
  modalOpen,
  modalRegisterBodyOverride,
} from '../interfaces/common/ComplexModal';
import { FlexItem } from '../components/Flex';
import { Window } from '../layouts';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import { TemporaryNotice } from './common/TemporaryNotice';

const severities = {
  'Minor': 'lightgray',
  'Medium': 'good',
  'Harmful': 'average',
  'Dangerous!': 'bad',
  'BIOHAZARD THREAT!': 'darkred',
};

const medStatusStyles = {
  '*Deceased*': 'deceased',
  '*SSD*': 'ssd',
  'Physically Unfit': 'physically_unfit',
  'Disabled': 'disabled',
};

const doEdit = (context, field) => {
  modalOpen(context, 'edit', {
    field: field.edit,
    value: field.value,
  });
};

const virusModalBodyOverride = (modal, context) => {
  const virus = modal.args;
  return (
    <Section level={2} m="-1rem" pb="1rem" title={virus.name || 'Virus'}>
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Number of stages">
            {virus.max_stages}
          </LabeledList.Item>
          <LabeledList.Item label="Spread">
            {virus.spread_text} Transmission
          </LabeledList.Item>
          <LabeledList.Item label="Possible cure">
            {virus.cure}
          </LabeledList.Item>
          <LabeledList.Item label="Notes">{virus.desc}</LabeledList.Item>
          <LabeledList.Item label="Severity" color={severities[virus.severity]}>
            {virus.severity}
          </LabeledList.Item>
        </LabeledList>
      </Box>
    </Section>
  );
};

export const MedicalRecords = (_properties, context) => {
  const { data } = useBackend(context);
  const { loginState, screen } = data;
  if (!loginState.logged_in) {
    return (
      <Window resizable>
        <Window.Content>
          <LoginScreen />
        </Window.Content>
      </Window>
    );
  }

  let body;
  if (screen === 2) {
    // List Records
    body = <MedicalRecordsList />;
  } else if (screen === 3) {
    // Record Maintenance
    body = <MedicalRecordsMaintenance />;
  } else if (screen === 4) {
    // View Records
    body = <MedicalRecordsView />;
  } else if (screen === 5) {
    // Virus Database
    body = <MedicalRecordsViruses />;
  } else if (screen === 6) {
    // Medbot Tracking
    body = <MedicalRecordsMedbots />;
  }

  return (
    <Window resizable>
      <ComplexModal />
      <Window.Content className="Layout__content--flexColumn">
        <LoginInfo />
        <TemporaryNotice />
        <MedicalRecordsNavigation />
        <Section height="100%" flexGrow="1">
          {body}
        </Section>
      </Window.Content>
    </Window>
  );
};

const MedicalRecordsList = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { records } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortId, _setSortId] = useLocalState(context, 'sortId', 'name');
  const [sortOrder, _setSortOrder] = useLocalState(context, 'sortOrder', true);
  return (
    <Flex direction="column" height="100%">
      <Flex>
        <FlexItem>
          <Button
            content="Manage Records"
            icon="wrench"
            ml="0.25rem"
            onClick={() => act('screen', { screen: 3 })}
          />
        </FlexItem>
        <FlexItem grow="1" ml="0.5rem">
          <Input
            placeholder="Search by Name, ID, Physical Status, or Mental Status"
            width="100%"
            onInput={(e, value) => setSearchText(value)}
          />
        </FlexItem>
      </Flex>
      <Section flexGrow="1" mt="0.5rem">
        <Table className="MedicalRecords__list">
          <Table.Row bold>
            <SortButton id="name">Name</SortButton>
            <SortButton id="id">ID</SortButton>
            <SortButton id="rank">Assignment</SortButton>
            <SortButton id="p_stat">Patient Status</SortButton>
            <SortButton id="m_stat">Mental Status</SortButton>
          </Table.Row>
          {records
            .filter(
              createSearch(searchText, (record) => {
                return (
                  record.name +
                  '|' +
                  record.id +
                  '|' +
                  record.rank +
                  '|' +
                  record.p_stat +
                  '|' +
                  record.m_stat
                );
              })
            )
            .sort((a, b) => {
              const i = sortOrder ? 1 : -1;
              return a[sortId].localeCompare(b[sortId]) * i;
            })
            .map((record) => (
              <Table.Row
                key={record.id}
                className={
                  'MedicalRecords__listRow--' + medStatusStyles[record.p_stat]
                }
                onClick={() => act('view_record', { view_record: record.ref })}
              >
                <Table.Cell>
                  <Icon name="user" /> {record.name}
                </Table.Cell>
                <Table.Cell>{record.id}</Table.Cell>
                <Table.Cell>{record.rank}</Table.Cell>
                <Table.Cell>{record.p_stat}</Table.Cell>
                <Table.Cell>{record.m_stat}</Table.Cell>
              </Table.Row>
            ))}
        </Table>
      </Section>
    </Flex>
  );
};

const MedicalRecordsMaintenance = (_properties, context) => {
  const { act } = useBackend(context);
  return (
    <Fragment>
      <Button icon="download" content="Backup to Disk" disabled />
      <br />
      <Button
        icon="upload"
        content="Upload from Disk"
        my="0.5rem"
        disabled
      />{' '}
      <br />
      <Button.Confirm
        icon="trash"
        content="Delete All Medical Records"
        onClick={() => act('del_all_med_records')}
      />
    </Fragment>
  );
};

const MedicalRecordsView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { medical, printing } = data;
  return (
    <Fragment>
      <Section
        title="General Data"
        level={2}
        mt="-6px"
        buttons={
          <Button
            icon={printing ? 'spinner' : 'print'}
            disabled={printing}
            iconSpin={!!printing}
            content="Print Record"
            ml="0.5rem"
            onClick={() => act('print_record')}
          />
        }
      >
        <MedicalRecordsViewGeneral />
      </Section>
      <Section
        title="Medical Data"
        level={2}
        buttons={
          <Button.Confirm
            icon="trash"
            disabled={!!medical.empty}
            content="Delete Medical Record"
            onClick={() => act('del_med_record')}
          />
        }
      >
        <MedicalRecordsViewMedical />
      </Section>
    </Fragment>
  );
};

const MedicalRecordsViewGeneral = (_properties, context) => {
  const { data } = useBackend(context);
  const { general } = data;
  if (!general || !general.fields) {
    return <Box color="bad">General records lost!</Box>;
  }
  return (
    <Fragment>
      <Box width="50%" float="left">
        <LabeledList>
          {general.fields.map((field, i) => (
            <LabeledList.Item key={i} label={field.field}>
              <Box height="20px" display="inline-block">
                {field.value}
              </Box>
              {!!field.edit && (
                <Button
                  icon="pen"
                  ml="0.5rem"
                  onClick={() => doEdit(context, field)}
                />
              )}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Box>
      <Box width="50%" float="right" textAlign="right">
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

const MedicalRecordsViewMedical = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { medical } = data;
  if (!medical || !medical.fields) {
    return (
      <Box color="bad">
        Medical records lost!
        <Button
          icon="pen"
          content="New Record"
          ml="0.5rem"
          onClick={() => act('new_med_record')}
        />
      </Box>
    );
  }
  return (
    <Fragment>
      <LabeledList>
        {medical.fields.map((field, i) => (
          <LabeledList.Item key={i} label={field.field} prewrap>
            {field.value}
            <Button
              icon="pen"
              ml="0.5rem"
              mb={field.line_break ? '1rem' : 'initial'}
              onClick={() => doEdit(context, field)}
            />
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
            onClick={() => modalOpen(context, 'add_comment')}
          />
        }
      >
        {medical.comments.length === 0 ? (
          <Box color="label">No comments found.</Box>
        ) : (
          medical.comments.map((comment, i) => (
            <Box key={i} prewrap>
              <Box color="label" display="inline">
                {comment.header}
              </Box>
              <br />
              {comment.text}
              <Button
                icon="comment-slash"
                color="bad"
                ml="0.5rem"
                onClick={() => act('del_comment', { del_comment: i + 1 })}
              />
            </Box>
          ))
        )}
      </Section>
    </Fragment>
  );
};

const MedicalRecordsViruses = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { virus } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortId2, _setSortId2] = useLocalState(context, 'sortId2', 'name');
  const [sortOrder2, _setSortOrder2] = useLocalState(
    context,
    'sortOrder2',
    true
  );
  return (
    <Flex direction="column" height="100%">
      <Flex>
        <FlexItem grow="1" ml="0.5rem">
          <Input
            placeholder="Search by Name, Max Stages, or Severity"
            width="100%"
            onInput={(e, value) => setSearchText(value)}
          />
        </FlexItem>
      </Flex>
      <Section flexGrow="1" mt="0.5rem">
        <Table className="MedicalRecords__list">
          <Table.Row bold>
            <SortButton2 id="name">Name</SortButton2>
            <SortButton2 id="max_stages">Max Stages</SortButton2>
            <SortButton2 id="severity">Severity</SortButton2>
          </Table.Row>
          {virus
            .filter(
              createSearch(searchText, (vir) => {
                return vir.name + '|' + vir.max_stages + '|' + vir.severity;
              })
            )
            .sort((a, b) => {
              const i = sortOrder2 ? 1 : -1;
              return a[sortId2].localeCompare(b[sortId2]) * i;
            })
            .map((vir) => (
              <Table.Row
                key={vir.id}
                className={'MedicalRecords__listVirus--' + vir.severity}
                onClick={() => act('vir', { vir: vir.D })}
              >
                <Table.Cell>
                  <Icon name="virus" /> {vir.name}
                </Table.Cell>
                <Table.Cell>{vir.max_stages}</Table.Cell>
                <Table.Cell color={severities[vir.severity]}>
                  {vir.severity}
                </Table.Cell>
              </Table.Row>
            ))}
        </Table>
      </Section>
    </Flex>
  );
};

const MedicalRecordsMedbots = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { medbots } = data;
  if (medbots.length === 0) {
    return <Box color="label">There are no Medibots.</Box>;
  }
  return (
    <Flex direction="column" height="100%">
      <Section flexGrow="1" mt="0.5rem">
        <Table className="MedicalRecords__list">
          <Table.Row bold>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>Area</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Chemicals</Table.Cell>
          </Table.Row>
          {medbots.map((medbot) => (
            <Table.Row
              key={medbot.id}
              className={'MedicalRecords__listMedbot--' + medbot.on}
            >
              <Table.Cell>
                <Icon name="medical" /> {medbot.name}
              </Table.Cell>
              <Table.Cell>
                {medbot.area || 'Unknown'} ({medbot.x}, {medbot.y})
              </Table.Cell>
              <Table.Cell>
                {medbot.on ? (
                  <Box color="good">Online</Box>
                ) : (
                  <Box color="average">Offline</Box>
                )}
              </Table.Cell>
              <Table.Cell>
                {medbot.use_beaker
                  ? 'Reservoir: ' +
                    medbot.total_volume +
                    '/' +
                    medbot.maximum_volume
                  : 'Using internal synthesizer'}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Flex>
  );
};

const SortButton = (properties, context) => {
  const [sortId, setSortId] = useLocalState(context, 'sortId', 'name');
  const [sortOrder, setSortOrder] = useLocalState(context, 'sortOrder', true);
  const { id, children } = properties;
  return (
    <Table.Cell>
      <Button
        color={sortId !== id && 'transparent'}
        width="100%"
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
        {sortId === id && (
          <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />
        )}
      </Button>
    </Table.Cell>
  );
};

const SortButton2 = (properties, context) => {
  const [sortId2, setSortId2] = useLocalState(context, 'sortId2', 'name');
  const [sortOrder2, setSortOrder2] = useLocalState(
    context,
    'sortOrder2',
    true
  );
  const { id, children } = properties;
  return (
    <Table.Cell>
      <Button
        color={sortId2 !== id && 'transparent'}
        width="100%"
        onClick={() => {
          if (sortId2 === id) {
            setSortOrder2(!sortOrder2);
          } else {
            setSortId2(id);
            setSortOrder2(true);
          }
        }}
      >
        {children}
        {sortId2 === id && (
          <Icon name={sortOrder2 ? 'sort-up' : 'sort-down'} ml="0.25rem;" />
        )}
      </Button>
    </Table.Cell>
  );
};

const MedicalRecordsNavigation = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { screen, general } = data;
  return (
    <Tabs>
      <Tabs.Tab
        selected={screen === 2}
        onClick={() => {
          act('screen', { screen: 2 });
        }}
      >
        <Icon name="list" />
        List Records
      </Tabs.Tab>
      <Tabs.Tab
        selected={screen === 5}
        onClick={() => {
          act('screen', { screen: 5 });
        }}
      >
        <Icon name="database" />
        Virus Database
      </Tabs.Tab>
      <Tabs.Tab
        selected={screen === 6}
        onClick={() => act('screen', { screen: 6 })}
      >
        <Icon name="plus-square" />
        Medibot Tracking
      </Tabs.Tab>
      {screen === 3 && (
        <Tabs.Tab selected={screen === 3}>
          <Icon name="wrench" />
          Record Maintenance
        </Tabs.Tab>
      )}
      {screen === 4 && general && !general.empty && (
        <Tabs.Tab selected={screen === 4}>
          <Icon name="file" />
          Record: {general.fields[0].value}
        </Tabs.Tab>
      )}
    </Tabs>
  );
};

modalRegisterBodyOverride('virus', virusModalBodyOverride);
