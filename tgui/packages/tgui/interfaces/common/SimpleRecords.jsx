import { filter, sortBy } from 'common/collections';
import { useState } from 'react';
import { Box, Button, Input, LabeledList, Section } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../../backend';

export const SimpleRecords = (props) => {
  const { records } = props.data;

  return (
    <Box>
      {!records ? <SelectionView data={props.data} /> : <RecordView data={props.data} recordType={props.recordType} />}
    </Box>
  );
};

const SelectionView = (props) => {
  const { act } = useBackend();
  const { recordsList } = props.data;

  const [searchText, setSearchText] = useState('');

  // Search for peeps
  const SelectMembers = (people, searchText = '') => {
    let members = filter(recordsList, (member) => member?.Name);
    if (searchText) {
      members = filter(
        members,
        createSearch(searchText, (member) => member.Name)
      );
    }
    return sortBy(members, (member) => member.Name);
  };

  const formattedRecords = SelectMembers(recordsList, searchText);

  return (
    <Box>
      <Input fluid mb={1} placeholder="Search records..." onChange={(value) => setSearchText(value)} />
      {formattedRecords.map((r) => (
        <Box key={r}>
          <Button mb={0.5} content={r.Name} icon="user" onClick={() => act('Records', { target: r.uid })} />
        </Box>
      ))}
    </Box>
  );
};

const RecordView = (props) => {
  const { act } = useBackend();
  const { records } = props.data;

  const { general, medical, security } = records;

  let secondaryRecord;
  switch (props.recordType) {
    case 'MED':
      secondaryRecord = (
        <Section level={2} title="Medical Data">
          {medical ? (
            <LabeledList>
              <LabeledList.Item label="Blood Type">{medical.blood_type}</LabeledList.Item>
              <LabeledList.Item label="Minor Disabilities">{medical.mi_dis}</LabeledList.Item>
              <LabeledList.Item label="Details">{medical.mi_dis_d}</LabeledList.Item>
              <LabeledList.Item label="Major Disabilities">{medical.ma_dis}</LabeledList.Item>
              <LabeledList.Item label="Details">{medical.ma_dis_d}</LabeledList.Item>
              <LabeledList.Item label="Allergies">{medical.alg}</LabeledList.Item>
              <LabeledList.Item label="Details">{medical.alg_d}</LabeledList.Item>
              <LabeledList.Item label="Current Diseases">{medical.cdi}</LabeledList.Item>
              <LabeledList.Item label="Details">{medical.cdi_d}</LabeledList.Item>
              <LabeledList.Item label="Important Notes" preserveWhitespace>
                {medical.notes}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="red" bold>
              {'Medical record lost!'}
            </Box>
          )}
        </Section>
      );
      break;
    case 'SEC':
      secondaryRecord = (
        <Section level={2} title="Security Data">
          {security ? (
            <LabeledList>
              <LabeledList.Item label="Criminal Status">{security.criminal}</LabeledList.Item>
              <LabeledList.Item label="Minor Crimes">{security.mi_crim}</LabeledList.Item>
              <LabeledList.Item label="Details">{security.mi_crim_d}</LabeledList.Item>
              <LabeledList.Item label="Major Crimes">{security.ma_crim}</LabeledList.Item>
              <LabeledList.Item label="Details">{security.ma_crim_d}</LabeledList.Item>
              <LabeledList.Item label="Important Notes" preserveWhitespace>
                {security.notes}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="red" bold>
              {'Security record lost!'}
            </Box>
          )}
        </Section>
      );
      break;
  }

  return (
    <Box>
      <Section title="General Data">
        {general ? (
          <LabeledList>
            <LabeledList.Item label="Name">{general.name}</LabeledList.Item>
            <LabeledList.Item label="Sex">{general.sex}</LabeledList.Item>
            <LabeledList.Item label="Species">{general.species}</LabeledList.Item>
            <LabeledList.Item label="Age">{general.age}</LabeledList.Item>
            <LabeledList.Item label="Rank">{general.rank}</LabeledList.Item>
            <LabeledList.Item label="Fingerprint">{general.fingerprint}</LabeledList.Item>
            <LabeledList.Item label="Physical Status">{general.p_stat}</LabeledList.Item>
            <LabeledList.Item label="Mental Status">{general.m_stat}</LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="red" bold>
            General record lost!
          </Box>
        )}
      </Section>
      {secondaryRecord}
    </Box>
  );
};
