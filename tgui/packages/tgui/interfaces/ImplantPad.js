import { useBackend } from '../backend';
import { Button, Section, Box } from '../components';
import { LabeledList, LabeledListItem } from '../components/LabeledList';
import { Window } from '../layouts';

export const ImplantPad = (props, context) => {
  const { act, data } = useBackend(context);
  const { implant, contains_case } = data;

  return (
    <Window resizable>
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
                <LabeledListItem label="Life">{implant.life}</LabeledListItem>
                <LabeledListItem label="Notes">{implant.notes}</LabeledListItem>
                <LabeledListItem label="Function">
                  {implant.function}
                </LabeledListItem>
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
