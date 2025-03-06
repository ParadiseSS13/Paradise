import { useBackend } from '../../backend';
import { LabeledList, Section, Box } from '../../components';

export const pda_supplyrecords = (props, context) => {
  const { act, data } = useBackend(context);
  const { supply } = data;
  const { shuttle_loc, shuttle_time, shuttle_moving, approved, approved_count, requests, requests_count } = supply;

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Shuttle Status">
          {shuttle_moving ? <Box>In transit {shuttle_time}</Box> : <Box>{shuttle_loc}</Box>}
        </LabeledList.Item>
      </LabeledList>
      <Section mt={1} title="Requested Orders">
        {requests_count > 0 &&
          requests.map((o) => (
            <Box key={o}>
              #{o.Number} - &quot;{o.Name}&quot; for &quot;{o.OrderedBy}&quot;
            </Box>
          ))}
      </Section>
      <Section title="Approved Orders">
        {approved_count > 0 &&
          // By the way, ApprovedBy is actually the
          // person who ordered it
          // You can really see the copypaste in cargo code
          approved.map((o) => (
            <Box key={o}>
              #{o.Number} - &quot;{o.Name}&quot; for &quot;{o.ApprovedBy}&quot;
            </Box>
          ))}
      </Section>
    </Box>
  );
};
