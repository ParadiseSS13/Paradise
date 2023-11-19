import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
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
import { Window } from '../layouts';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import { TemporaryNotice } from './common/TemporaryNotice';
import { RecordsTable } from './common/RecordsTable';

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

const MedicalRecordsList = (props, context) => {
  const { act, data } = useBackend(context);
  const { records } = data;
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
        { id: 'p_stat', name: 'Patient Status' },
        { id: 'm_stat', name: 'Mental Status' },
      ]}
      data={records}
      datumID={(datum) => datum.ref}
      leftButtons={
        <Button
          content="Manage Records"
          icon="wrench"
          onClick={() => act('screen', { screen: 3 })}
        />
      }
      searchPlaceholder="Search by Name, ID, Physical Status, or Mental Status"
      datumRowProps={(datum) => ({
        className: `MedicalRecords__listRow--${medStatusStyles[datum.p_stat]}`,
        onClick: () => act('view_record', { view_record: datum.ref }),
      })}
    />
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

const MedicalRecordsViruses = (props, context) => {
  const { act, data } = useBackend(context);
  const { virus } = data;
  return (
    <RecordsTable
      columns={[
        {
          id: 'name',
          name: 'Name',
          datum: {
            children: (value) => (
              <>
                <Icon name="virus" /> {value}
              </>
            ),
          },
        },
        { id: 'max_stages', name: 'Max Stages' },
        {
          id: 'severity',
          name: 'Severity',
          datum: {
            props: (value) => ({
              color: severities[value],
            }),
          },
        },
      ]}
      data={virus}
      datumID={(datum) => datum.id}
      searchPlaceholder="Search by Name, Max Stages, or Severity"
      datumRowProps={(datum) => ({
        className: `MedicalRecords__listVirus--${datum.severity}`,
        onClick: () => act('vir', { vir: datum.D }),
      })}
    />
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
