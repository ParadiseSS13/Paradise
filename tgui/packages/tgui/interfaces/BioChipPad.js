import { useBackend } from '../backend';
import { Button, Section, Box, LabeledList } from '../components';
import { Window } from '../layouts';

export const BioChipPad = (props, context) => {
  const { act, data } = useBackend(context);
  const { implant, contains_case } = data;

  return (
    <Window width={410} height={400}>
      <Window.Content>
        <Section title="Bio-chip Mini-Computer">
          {implant && contains_case ? (
            <>
              <Box bold mb={2}>
                <img
                  src={`data:image/jpeg;base64,${implant.image}`}
                  ml={0}
                  mr={2}
                  style={{
                    'vertical-align': 'middle',
                    width: '32px',
                  }}
                />
                {implant.name}
              </Box>
              <LabeledList>
                <LabeledList.Item label="Life">{implant.life}</LabeledList.Item>
                <LabeledList.Item label="Notes">
                  {implant.notes}
                </LabeledList.Item>
                <LabeledList.Item label="Function">
                  {implant.function}
                </LabeledList.Item>
              </LabeledList>
            </>
          ) : contains_case ? (
            <Box>This bio-chip case has no implant!</Box>
          ) : (
            <Box>Please insert a bio-chip casing!</Box>
          )}
          <Button
            mt={2}
            content="Eject Case"
            icon="eject"
            disabled={!contains_case}
            onClick={() => act('eject_case')}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
