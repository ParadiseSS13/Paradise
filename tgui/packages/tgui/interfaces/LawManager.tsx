import { Box, Button, LabeledList, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BooleanLike } from 'tgui-core/react';

type LawManagerData = {
  isAdmin: BooleanLike;
  isSlaved: BooleanLike;
  isMalf: BooleanLike;
  isAIMalf: BooleanLike;
  view: BooleanLike;
};

export const LawManager = (props) => {
  const { act, data } = useBackend<LawManagerData>();
  const { isAdmin, isSlaved, isMalf, isAIMalf, view } = data;

  return (
    <Window width={800} height={isMalf ? 620 : 365}>
      <Window.Content scrollable>
        {!!(isAdmin && isSlaved) && <NoticeBox>This unit is slaved to {isSlaved}.</NoticeBox>}
        {!!(isMalf || isAIMalf) && (
          <Box>
            <Button content="Law Management" selected={view === 0} onClick={() => act('set_view', { set_view: 0 })} />
            <Button content="Lawsets" selected={view === 1} onClick={() => act('set_view', { set_view: 1 })} />
          </Box>
        )}
        {!!(view === 0) && <LawManagementView />}
        {!!(view === 1) && <LawsetsView />}
      </Window.Content>
    </Window>
  );
};

type Law = {
  law: string;
  index: number;
  state: number;
  ref: string;
};

type Channel = {
  channel: string;
};

type LawManagementViewData = {
  has_zeroth_laws: number;
  zeroth_laws: Law[];
  has_ion_laws: number;
  ion_laws: Law[];
  ion_law_nr: BooleanLike;
  has_inherent_laws: number;
  inherent_laws: Law[];
  has_supplied_laws: number;
  supplied_laws: Law[];
  channels: Channel[];
  channel: string;
  isMalf: BooleanLike;
  isAdmin: BooleanLike;
  zeroth_law: BooleanLike;
  ion_law: string;
  inherent_law: string;
  supplied_law: string;
  supplied_law_position: number;
};

const LawManagementView = (props) => {
  const { act, data } = useBackend<LawManagementViewData>();
  const {
    has_zeroth_laws,
    zeroth_laws,
    has_ion_laws,
    ion_laws,
    ion_law_nr,
    has_inherent_laws,
    inherent_laws,
    has_supplied_laws,
    supplied_laws,
    channels,
    channel,
    isMalf,
    isAdmin,
    zeroth_law,
    ion_law,
    inherent_law,
    supplied_law,
    supplied_law_position,
  } = data;
  return (
    <>
      {!!has_zeroth_laws && <LawTable title="ERR_NULL_VALUE" laws={zeroth_laws} isMalf={isMalf} />}
      {!!has_ion_laws && <LawTable title={`${ion_law_nr}`} laws={ion_laws} isMalf={isMalf} />}
      {!!has_inherent_laws && <LawTable title="Inherent" laws={inherent_laws} isMalf={isMalf} />}
      {!!has_supplied_laws && <LawTable title="Supplied" laws={supplied_laws} isMalf={isMalf} />}
      <Section title="Statement Settings">
        <LabeledList>
          <LabeledList.Item label="Statement Channel">
            {channels.map((c) => (
              <Button
                content={c.channel}
                key={c.channel}
                selected={c.channel === channel}
                onClick={() => act('law_channel', { law_channel: c.channel })}
              />
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="State Laws">
            <Button content="State Laws" onClick={() => act('state_laws')} />
          </LabeledList.Item>
          <LabeledList.Item label="Law Notification">
            <Button content="Notify" onClick={() => act('notify_laws')} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      {!!isMalf && (
        <Section title="Add Laws">
          <Table>
            <Table.Row header>
              <Table.Cell width="10%">Type</Table.Cell>
              <Table.Cell width="60%">Law</Table.Cell>
              <Table.Cell width="10%">Index</Table.Cell>
              <Table.Cell width="20%">Actions</Table.Cell>
            </Table.Row>
            {!!(isAdmin && !has_zeroth_laws) && (
              <Table.Row>
                <Table.Cell>Zero</Table.Cell>
                <Table.Cell>{zeroth_law}</Table.Cell>
                <Table.Cell>N/A</Table.Cell>
                <Table.Cell>
                  <Button content="Edit" icon="pencil-alt" onClick={() => act('change_zeroth_law')} />
                  <Button content="Add" icon="plus" onClick={() => act('add_zeroth_law')} />
                </Table.Cell>
              </Table.Row>
            )}
            <Table.Row>
              <Table.Cell>Ion</Table.Cell>
              <Table.Cell>{ion_law}</Table.Cell>
              <Table.Cell>N/A</Table.Cell>
              <Table.Cell>
                <Button content="Edit" icon="pencil-alt" onClick={() => act('change_ion_law')} />
                <Button content="Add" icon="plus" onClick={() => act('add_ion_law')} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Inherent</Table.Cell>
              <Table.Cell>{inherent_law}</Table.Cell>
              <Table.Cell>N/A</Table.Cell>
              <Table.Cell>
                <Button content="Edit" icon="pencil-alt" onClick={() => act('change_inherent_law')} />
                <Button content="Add" icon="plus" onClick={() => act('add_inherent_law')} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Supplied</Table.Cell>
              <Table.Cell>{supplied_law}</Table.Cell>
              <Table.Cell>
                <Button content={supplied_law_position} onClick={() => act('change_supplied_law_position')} />
              </Table.Cell>
              <Table.Cell>
                <Button content="Edit" icon="pencil-alt" onClick={() => act('change_supplied_law')} />
                <Button content="Add" icon="plus" onClick={() => act('add_supplied_law')} />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      )}
    </>
  );
};

type Lawset = {
  name: string;
  header: string;
  ref: string;
  laws: LawManagementViewData;
};

type LawsetsViewData = {
  law_sets: Lawset[];
};

const LawsetsView = (props) => {
  const { act, data } = useBackend<LawsetsViewData>();
  const { law_sets } = data;
  return (
    <Box>
      {law_sets.map((l) => (
        <Section
          key={l.name}
          title={l.name + ' - ' + l.header}
          buttons={
            <Button
              content="Load Laws"
              icon="download"
              onClick={() => act('transfer_laws', { transfer_laws: l.ref })}
            />
          }
        >
          <LabeledList>
            {l.laws.has_ion_laws > 0 &&
              l.laws.ion_laws.map((il) => (
                <LabeledList.Item key={il.index} label={il.index}>
                  {il.law}
                </LabeledList.Item>
              ))}
            {l.laws.has_zeroth_laws > 0 &&
              l.laws.zeroth_laws.map((zl) => (
                <LabeledList.Item key={zl.index} label={zl.index}>
                  {zl.law}
                </LabeledList.Item>
              ))}
            {l.laws.has_inherent_laws > 0 &&
              l.laws.inherent_laws.map((il) => (
                <LabeledList.Item key={il.index} label={il.index}>
                  {il.law}
                </LabeledList.Item>
              ))}
            {l.laws.has_supplied_laws > 0 &&
              l.laws.inherent_laws.map((sl) => (
                <LabeledList.Item key={sl.index} label={sl.index}>
                  {sl.law}
                </LabeledList.Item>
              ))}
          </LabeledList>
        </Section>
      ))}
    </Box>
  );
};

type LawTableProps = {
  isMalf: BooleanLike;
  laws: Law[];
  title: string;
};

const LawTable = (props: LawTableProps) => {
  const { act, data } = useBackend();
  const { isMalf, laws, title } = props;
  return (
    <Section title={title + ' Laws'}>
      <Table>
        <Table.Row header>
          <Table.Cell width="10%">Index</Table.Cell>
          <Table.Cell width="69%">Law</Table.Cell>
          <Table.Cell width="21%">State?</Table.Cell>
        </Table.Row>
        {laws.map((l) => (
          <Table.Row key={l.law}>
            <Table.Cell>{l.index}</Table.Cell>
            <Table.Cell>{l.law}</Table.Cell>
            <Table.Cell>
              <Button
                content={l.state ? 'Yes' : 'No'}
                selected={l.state}
                onClick={() => act('state_law', { ref: l.ref, state_law: l.state ? 0 : 1 })}
              />
              {!!isMalf && (
                <>
                  <Button content="Edit" icon="pencil-alt" onClick={() => act('edit_law', { edit_law: l.ref })} />
                  <Button
                    content="Delete"
                    icon="trash"
                    color="red"
                    onClick={() => act('delete_law', { delete_law: l.ref })}
                  />
                </>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
