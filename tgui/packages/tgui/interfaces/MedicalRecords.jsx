import { useContext, useState } from 'react';
import { Box, Button, Icon, Input, LabeledList, ProgressBar, Section, Stack, Table, Tabs } from 'tgui-core/components';
import { createSearch, decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal, modalOpen, modalRegisterBodyOverride } from './common/ComplexModal';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import SortableTableContext from './common/SortableTableContext';
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

const doEdit = (field) => {
  modalOpen('edit', {
    field: field.edit,
    value: field.value,
  });
};

const virusModalBodyOverride = (modal) => {
  const virus = modal.args;
  return (
    <Section m="-1rem" pb="1.5rem" title={virus.name || 'Virus'}>
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Number of stages">{virus.max_stages}</LabeledList.Item>
          <LabeledList.Item label="Spread">{virus.spread_text} Transmission</LabeledList.Item>
          <LabeledList.Item label="Possible cure">{virus.cure}</LabeledList.Item>
          <LabeledList.Item label="Notes">{virus.desc}</LabeledList.Item>
          <LabeledList.Item label="Severity" color={severities[virus.severity]}>
            {virus.severity}
          </LabeledList.Item>
        </LabeledList>
      </Box>
    </Section>
  );
};

export const MedicalRecords = (_properties) => {
  const { data } = useBackend();
  const { loginState, screen } = data;
  if (!loginState.logged_in) {
    return (
      <Window width={800} height={900}>
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
    // Virology Goals
    body = <MedicalRecordsGoals />;
  } else if (screen === 7) {
    // Medbot Tracking
    body = <MedicalRecordsMedbots />;
  }

  return (
    <Window width={800} height={900}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <LoginInfo />
          <TemporaryNotice />
          <MedicalRecordsNavigation />
          {body}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MedicalRecordsList = () => (
  <SortableTableContext.Default sortId="name">
    <MedicalRecordsListBase />
  </SortableTableContext.Default>
);

const MedicalRecordsListBase = (_properties) => {
  const { act, data } = useBackend();
  const { records } = data;
  const [searchText, setSearchText] = useState('');
  const { sortId, sortOrder } = useContext(SortableTableContext);
  return (
    <>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button content="Manage Records" icon="wrench" ml="0.25rem" onClick={() => act('screen', { screen: 3 })} />
          </Stack.Item>
          <Stack.Item grow>
            <Input
              fluid
              placeholder="Search by Name, ID, Physical Status, or Mental Status"
              onChange={(value) => setSearchText(value)}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow mt={0.5}>
        <Section fill scrollable>
          <Table className="MedicalRecords__list">
            <Table.Row bold>
              <SortButton id="name">Name</SortButton>
              <SortButton id="id">ID</SortButton>
              <SortButton id="dna">DNA</SortButton>
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
                    record.dna +
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
                  className={'MedicalRecords__listRow--' + medStatusStyles[record.p_stat]}
                  onClick={() => act('view_record', { view_record: record.ref })}
                >
                  <Table.Cell>
                    <Icon name="user" /> {record.name}
                  </Table.Cell>
                  <Table.Cell>{record.id}</Table.Cell>
                  <Table.Cell>{record.dna}</Table.Cell>
                  <Table.Cell>{record.rank}</Table.Cell>
                  <Table.Cell>{record.p_stat}</Table.Cell>
                  <Table.Cell>{record.m_stat}</Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </Section>
      </Stack.Item>
    </>
  );
};

const MedicalRecordsMaintenance = (_properties) => {
  const { act } = useBackend();
  return (
    <Stack.Item grow textAlign="center">
      <Section fill>
        <Stack.Item grow>
          <Button fluid lineHeight={3} icon="download" content="Backup to Disk" disabled />
        </Stack.Item>
        <Stack.Item grow>
          <Button fluid lineHeight={3} icon="upload" content="Upload from Disk" my="0.5rem" disabled />{' '}
        </Stack.Item>
        <Stack.Item grow>
          <Button.Confirm
            fluid
            lineHeight={3}
            icon="trash"
            content="Delete All Medical Records"
            onClick={() => act('del_all_med_records')}
          />
        </Stack.Item>
      </Section>
    </Stack.Item>
  );
};

const MedicalRecordsView = (_properties) => {
  const { act, data } = useBackend();
  const { medical, printing } = data;
  return (
    <>
      <Stack.Item height="235px">
        <Section
          fill
          scrollable
          title="General Data"
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
      </Stack.Item>
      {!medical || !medical.fields ? (
        <Stack.Item grow color="bad">
          <Section
            fill
            title="Medical Data"
            buttons={<Button icon="pen" content="Create New Record" onClick={() => act('new_med_record')} />}
          >
            <Stack fill>
              <Stack.Item bold grow textAlign="center" fontSize={1.75} align="center" color="label">
                <Icon.Stack>
                  <Icon name="scroll" size={5} color="gray" />
                  <Icon name="slash" size={5} color="red" />
                </Icon.Stack>
                <br />
                Medical records lost!
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
              title="Medical Data"
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
          </Stack.Item>
          <MedicalRecordsViewComments />
        </>
      )}
    </>
  );
};

const MedicalRecordsViewGeneral = (_properties) => {
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
            <LabeledList.Item key={i} label={field.field}>
              <Box height="20px" inline>
                {field.value}
              </Box>
              {!!field.edit && <Button icon="pen" ml="0.5rem" onClick={() => doEdit(field)} />}
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
                marginTop: '2.5rem',
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

const MedicalRecordsViewMedical = (_properties) => {
  const { act, data } = useBackend();
  const { medical } = data;
  if (!medical || !medical.fields) {
    return (
      <Stack fill vertical>
        <Stack.Item grow color="bad">
          <Section fill>Medical records lost!</Section>
        </Stack.Item>
      </Stack>
    );
  }
  return (
    <Stack>
      <Stack.Item grow>
        <LabeledList>
          {medical.fields.map((field, i) => (
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
    </Stack>
  );
};

const MedicalRecordsViewComments = (_properties) => {
  const { act, data } = useBackend();
  const { medical } = data;
  return (
    <Stack.Item height="150px">
      <Section
        fill
        scrollable
        title="Comments/Log"
        buttons={<Button icon="comment" content="Add Entry" onClick={() => modalOpen('add_comment')} />}
      >
        {medical.comments.length === 0 ? (
          <Box color="label">No comments found.</Box>
        ) : (
          medical.comments.map((comment, i) => (
            <Box key={i}>
              <Box color="label" inline>
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
    </Stack.Item>
  );
};

const MedicalRecordsViruses = () => (
  <SortableTableContext.Default sortId="name">
    <MedicalRecordsVirusesBase />
  </SortableTableContext.Default>
);

const MedicalRecordsVirusesBase = (_properties) => {
  const { act, data } = useBackend();
  const { virus } = data;
  const [searchText, setSearchText] = useState('');
  const { sortId, sortOrder } = useContext(SortableTableContext);
  return (
    <>
      <Stack.Item grow>
        <Input
          ml="0.25rem"
          fluid
          placeholder="Search by Name, Max Stages, or Severity"
          onChange={(value) => setSearchText(value)}
        />
      </Stack.Item>
      <Stack fill vertical mt={0.5}>
        <Stack.Item grow>
          <Section fill scrollable>
            <Table className="MedicalRecords__list">
              <Table.Row bold>
                <SortButton id="name">Name</SortButton>
                <SortButton id="max_stages">Max Stages</SortButton>
                <SortButton id="severity">Severity</SortButton>
              </Table.Row>
              {virus
                .filter(
                  createSearch(searchText, (vir) => {
                    return vir.name + '|' + vir.max_stages + '|' + vir.severity;
                  })
                )
                .sort((a, b) => {
                  const i = sortOrder ? 1 : -1;
                  return a[sortId].localeCompare(b[sortId]) * i;
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
                    <Table.Cell color={severities[vir.severity]}>{vir.severity}</Table.Cell>
                  </Table.Row>
                ))}
            </Table>
          </Section>
        </Stack.Item>
      </Stack>
    </>
  );
};

const MedicalRecordsGoals = (_properties) => {
  const { act, data } = useBackend();
  const { goals } = data;
  return (
    <Section title="Virology Goals" fill>
      <Stack.Item grow>
        {(goals.length !== 0 &&
          goals.map((goal) => {
            return (
              <Stack.Item key={goal.id}>
                <Section title={goal.name}>
                  <Table>
                    <Table.Row header>
                      <Table.Cell textAlign="center">
                        <ProgressBar
                          value={goal.delivered}
                          minValue={0}
                          maxValue={goal.deliverygoal}
                          ranges={{
                            good: [goal.deliverygoal * 0.5, Infinity],
                            average: [goal.deliverygoal * 0.25, goal.deliverygoal * 0.5],
                            bad: [-Infinity, goal.deliverygoal * 0.25],
                          }}
                        >
                          {goal.delivered} / {goal.deliverygoal} Units
                        </ProgressBar>
                      </Table.Cell>
                    </Table.Row>
                  </Table>
                  <Box>{goal.report}</Box>
                </Section>
              </Stack.Item>
            );
          })) || (
          <Stack.Item>
            <Box textAlign="center">No Goals Detected</Box>
          </Stack.Item>
        )}
      </Stack.Item>
    </Section>
  );
};

const MedicalRecordsMedbots = (_properties) => {
  const { act, data } = useBackend();
  const { medbots } = data;
  if (medbots.length === 0) {
    return (
      <Stack.Item grow color="bad">
        <Section fill>
          <Stack fill>
            <Stack.Item bold grow textAlign="center" fontSize={1.75} align="center" color="label">
              <Icon.Stack>
                <Icon name="robot" size={5} color="gray" />
                <Icon name="slash" size={5} color="red" />
              </Icon.Stack>
              <br />
              There are no Medibots.
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    );
  }
  return (
    <Stack.Item grow>
      <Section fill scrollable>
        <Table className="MedicalRecords__list">
          <Table.Row bold>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>Area</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Chemicals</Table.Cell>
          </Table.Row>
          {medbots.map((medbot) => (
            <Table.Row key={medbot.id} className={'MedicalRecords__listMedbot--' + medbot.on}>
              <Table.Cell>
                <Icon name="medical" /> {medbot.name}
              </Table.Cell>
              <Table.Cell>
                {medbot.area || 'Unknown'} ({medbot.x}, {medbot.y})
              </Table.Cell>
              <Table.Cell>{medbot.on ? <Box color="good">Online</Box> : <Box color="average">Offline</Box>}</Table.Cell>
              <Table.Cell>
                {medbot.use_beaker
                  ? 'Reservoir: ' + medbot.total_volume + '/' + medbot.maximum_volume
                  : 'Using internal synthesizer'}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Stack.Item>
  );
};

const SortButton = (properties) => {
  const { sortId, setSortId, sortOrder, setSortOrder } = useContext(SortableTableContext);
  const { id, children } = properties;
  return (
    <Table.Cell>
      <Button
        fluid
        color={sortId !== id && 'transparent'}
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

const MedicalRecordsNavigation = (_properties) => {
  const { act, data } = useBackend();
  const { screen, general } = data;
  return (
    <Stack.Item m={0}>
      <Tabs>
        <Tabs.Tab
          icon="list"
          selected={screen === 2}
          onClick={() => {
            act('screen', { screen: 2 });
          }}
        >
          List Records
        </Tabs.Tab>
        <Tabs.Tab
          icon="database"
          selected={screen === 5}
          onClick={() => {
            act('screen', { screen: 5 });
          }}
        >
          Virus Database
        </Tabs.Tab>
        <Tabs.Tab
          icon="vial"
          selected={screen === 6}
          onClick={() => {
            act('screen', { screen: 6 });
          }}
        >
          Virology Goals
        </Tabs.Tab>
        <Tabs.Tab icon="plus-square" selected={screen === 7} onClick={() => act('screen', { screen: 7 })}>
          Medibot Tracking
        </Tabs.Tab>
        {screen === 3 && (
          <Tabs.Tab icon="wrench" selected={screen === 3}>
            Record Maintenance
          </Tabs.Tab>
        )}
        {screen === 4 && general && !general.empty && (
          <Tabs.Tab icon="file" selected={screen === 4}>
            Record: {general.fields[0].value}
          </Tabs.Tab>
        )}
      </Tabs>
    </Stack.Item>
  );
};

modalRegisterBodyOverride('virus', virusModalBodyOverride);
