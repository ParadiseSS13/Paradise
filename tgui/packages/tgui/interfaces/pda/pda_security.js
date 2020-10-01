import { useBackend, useLocalState } from "../../backend";
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { Box, Input, Button, Section, LabeledList } from "../../components";

export const pda_security = (props, context) => {
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
    security,
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
      <Section level={2} title="Security Data">
        {security ? (
          <LabeledList>
            <LabeledList.Item label="Criminal Status">
              {security.criminal}
            </LabeledList.Item>
            <LabeledList.Item label="Minor Crimes">
              {security.mi_crim}
            </LabeledList.Item>
            <LabeledList.Item label="Details">
              {security.mi_crim_d}
            </LabeledList.Item>
            <LabeledList.Item label="Major Crimes">
              {security.ma_crim}
            </LabeledList.Item>
            <LabeledList.Item label="Details">
              {security.ma_crim_d}
            </LabeledList.Item>
            <LabeledList.Item label="Important Notes">
              {security.notes}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="red" bold>
            Security record lost!
          </Box>
        )}
      </Section>
    </Box>
  );

};
