import { useBackend, useLocalState } from "../../backend";
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { Box, Input, Button, Section, LabeledList } from "../../components";

export const pda_medical = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    records,
  } = data;

  return (
    <Box>
      {!records ? (
        <SelectionView />
      ) : (
        <RecordView />
      )}
    </Box>
  );
};

const SelectionView = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    recordsList,
  } = data;

  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  // Search for peeps
  const SelectMembers = (people, searchText = '') => {
    const MemberSearch = createSearch(searchText, member => member.Name);
    return flow([
      // Null camera filter
      filter(member => member?.Name),
      // Optional search term
      searchText && filter(MemberSearch),
      // Slightly expensive, but way better than sorting in BYOND
      sortBy(member => member.Name),
    ])(recordsList);
  };

  const formattedRecords = SelectMembers(recordsList, searchText);

  return (
    <Box>
      <Input
        fluid
        mb={1}
        placeholder="Search records..."
        onInput={(e, value) => setSearchText(value)} />
      {formattedRecords.map(r => (
        <Box key={r}>
          <Button
            content={r.Name}
            icon="user"
            onClick={() => act('Records', { target: r.uid })}
          />
        </Box>
      ))}
    </Box>
  );
};

const RecordView = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    records,
  } = data;

  const {
    general,
    medical,
  } = records;

  return (
    <Box>
      <Section level={2} title="General Data">
        {general ? (
          <LabeledList>
            <LabeledList.Item label="Name">
              {general.name}
            </LabeledList.Item>
            <LabeledList.Item label="Sex">
              {general.sex}
            </LabeledList.Item>
            <LabeledList.Item label="Species">
              {general.species}
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              {general.age}
            </LabeledList.Item>
            <LabeledList.Item label="Rank">
              {general.rank}
            </LabeledList.Item>
            <LabeledList.Item label="Fingerprint">
              {general.fingerprint}
            </LabeledList.Item>
            <LabeledList.Item label="Physical Status">
              {general.p_stat}
            </LabeledList.Item>
            <LabeledList.Item label="Mental Status">
              {general.m_stat}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="red" bold>
            General record lost!
          </Box>
        )}
      </Section>
      <Section level={2} title="Medical Data">
        {medical ? (
          <LabeledList>
            <LabeledList.Item label="Blood Type">
              {medical.blood_type}
            </LabeledList.Item>
            <LabeledList.Item label="Minor Disabilities">
              {medical.mi_dis}
            </LabeledList.Item>
            <LabeledList.Item label="Details">
              {medical.mi_dis_d}
            </LabeledList.Item>
            <LabeledList.Item label="Major Disabilities">
              {medical.ma_dis}
            </LabeledList.Item>
            <LabeledList.Item label="Details">
              {medical.ma_dis_d}
            </LabeledList.Item>
            <LabeledList.Item label="Allergies">
              {medical.alg}
            </LabeledList.Item>
            <LabeledList.Item label="Details">
              {medical.alg_d}
            </LabeledList.Item>
            <LabeledList.Item label="Current Diseases">
              {medical.cdi}
            </LabeledList.Item>
            <LabeledList.Item label="Details">
              {medical.cdi_d}
            </LabeledList.Item>
            <LabeledList.Item label="Important Notes">
              {medical.notes}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="red" bold>
            Medical record lost!
          </Box>
        )}
      </Section>
    </Box>
  );

};
