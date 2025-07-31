import { Button, Icon, Section, Stack, Table, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { AccessList } from '../common/AccessList';
import { BooleanLike } from 'tgui-core/react';
import { CardComputerRecord, CardSkin, DepartmentPerson, IdCard, JobNames, JobSlotData } from './types';
import { CardComputerJobTransfer } from './job_transfer';
import { CardComputerJobPriority } from './job_priority';
import { AccessRegion } from '../common/AccessList';
import { CardComputerRecordsLog } from './records_log';
import { AuthBlock } from './auth_block';

export const SlashedIcon = (props: { title: string; name: string; text: string }) => {
  const { title, name, text } = props;
  return (
    <Section fill title={title}>
      <Stack fill>
        <Stack.Item bold grow textAlign="center" fontSize={1.75} align="center" color="label">
          <Icon.Stack>
            <Icon name={name} size={5} color="gray" />
            <Icon name="slash" size={5} color="red" />
          </Icon.Stack>
          <br />
          {text}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const CardComputerLoginWarning = () => <SlashedIcon title="Warning" name="user" text="Not logged in" />;
const CardComputerNoRecords = () => <SlashedIcon title="Records" name="scroll" text="No records" />;
const CardComputerNoCard = () => <SlashedIcon title="Card Missing" name="id-card" text="No card to modify" />;

export type CardComputerData = {
  all_centcom_skins: CardSkin[] | BooleanLike;
  auth_or_ghost: BooleanLike;
  authenticated: BooleanLike;
  can_terminate: BooleanLike;
  card_skins: CardSkin[];
  cooldown_time?: BooleanLike | string;
  is_centcom: BooleanLike;
  job_slots: JobSlotData[];
  job_formats: { string: string };
  jobs_dept?: string[];
  jobs: JobNames;
  mode: number;
  modifying_card?: IdCard;
  people_dept: DepartmentPerson[];
  priority_jobs: string[];
  records: CardComputerRecord[];
  regions: AccessRegion[];
  scanned_card?: IdCard;
  selectedAccess: number[];
  target_dept: number;
};

export const CardComputer = () => {
  const { act, data } = useBackend<CardComputerData>();
  const {
    all_centcom_skins,
    auth_or_ghost,
    authenticated,
    can_terminate,
    card_skins,
    cooldown_time,
    is_centcom,
    job_slots,
    job_formats,
    jobs_dept,
    jobs,
    mode,
    modifying_card,
    people_dept,
    priority_jobs,
    records,
    regions,
    scanned_card,
    selectedAccess,
    target_dept,
  } = data;

  let menuBlock = (
    <Tabs>
      <Tabs.Tab icon="id-card" selected={mode === 0} onClick={() => act('mode', { mode: 0 })}>
        Job Transfers
      </Tabs.Tab>
      {!target_dept && (
        <Tabs.Tab icon="id-card" selected={mode === 2} onClick={() => act('mode', { mode: 2 })}>
          Access Modification
        </Tabs.Tab>
      )}
      <Tabs.Tab icon="folder-open" selected={mode === 1} onClick={() => act('mode', { mode: 1 })}>
        Job Management
      </Tabs.Tab>
      <Tabs.Tab icon="scroll" selected={mode === 3} onClick={() => act('mode', { mode: 3 })}>
        Records
      </Tabs.Tab>
      <Tabs.Tab icon="users" selected={mode === 4} onClick={() => act('mode', { mode: 4 })}>
        Department
      </Tabs.Tab>
    </Tabs>
  );

  let bodyBlock;

  switch (mode) {
    case 0: // job transfer
      if (!authenticated || !scanned_card) {
        bodyBlock = <CardComputerLoginWarning />;
      } else if (!modifying_card) {
        bodyBlock = <CardComputerNoCard />;
      } else {
        bodyBlock = (
          <CardComputerJobTransfer
            target_dept={target_dept}
            card={modifying_card}
            can_terminate={can_terminate}
            is_centcom={is_centcom}
            jobs={jobs}
            job_colors={job_formats}
            jobs_dept={jobs_dept}
            card_skins={card_skins}
            all_centcom_skins={all_centcom_skins}
          />
        );
      }
      break;
    case 1: // job slot management
      if (!auth_or_ghost) {
        bodyBlock = <CardComputerLoginWarning />;
      } else {
        bodyBlock = (
          <CardComputerJobPriority
            cooldown_time={cooldown_time}
            target_dept={target_dept}
            priority_jobs={priority_jobs}
            job_slots={job_slots}
          />
        );
      }
      break;
    case 2: // access change
      if (!authenticated || !scanned_card) {
        bodyBlock = <CardComputerLoginWarning />;
      } else if (!modifying_card) {
        bodyBlock = <CardComputerNoCard />;
      } else {
        bodyBlock = (
          <AccessList
            accesses={regions}
            selectedList={selectedAccess}
            accessMod={(ref) =>
              act('set', {
                access: ref,
              })
            }
            grantAll={() => act('grant_all')}
            denyAll={() => act('clear_all')}
            grantDep={(ref) =>
              act('grant_region', {
                region: ref,
              })
            }
            denyDep={(ref) =>
              act('deny_region', {
                region: ref,
              })
            }
          />
        );
      }
      break;
    case 3: // records
      if (!authenticated) {
        bodyBlock = <CardComputerLoginWarning />;
      } else if (!records.length) {
        bodyBlock = <CardComputerNoRecords />;
      } else {
        bodyBlock = (
          <CardComputerRecordsLog
            authenticated={authenticated}
            records={records}
            target_dept={target_dept}
            is_centcom={is_centcom}
          />
        );
      }
      break;
    case 4: // department
      if (!authenticated || !scanned_card) {
        bodyBlock = <CardComputerLoginWarning />;
      } else {
        bodyBlock = (
          <Section fill scrollable title="Your Team">
            <Table>
              <Table.Row height={2}>
                <Table.Cell bold>Name</Table.Cell>
                <Table.Cell bold>Rank</Table.Cell>
                <Table.Cell bold>Sec Status</Table.Cell>
                <Table.Cell bold>Actions</Table.Cell>
              </Table.Row>
              {people_dept.map((record) => (
                <Table.Row key={record.title} height={2}>
                  <Table.Cell>{record.name}</Table.Cell>
                  <Table.Cell>{record.title}</Table.Cell>
                  <Table.Cell>{record.crimstat}</Table.Cell>
                  <Table.Cell>
                    <Button
                      disabled={!record.demotable}
                      onClick={() => act('remote_demote', { remote_demote: record.name })}
                    >
                      {record.buttontext}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        );
      }
      break;
    default:
      bodyBlock = (
        <Section title="Warning" color="red">
          ERROR: Unknown Mode.
        </Section>
      );
  }

  return (
    <Window width={800} height={800}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <AuthBlock scanned_card={scanned_card} modifying_card={modifying_card} />
          </Stack.Item>
          <Stack.Item>{menuBlock}</Stack.Item>
          <Stack.Item grow>{bodyBlock}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
