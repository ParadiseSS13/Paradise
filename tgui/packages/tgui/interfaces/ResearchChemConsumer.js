import { useBackend } from "../backend";
import { Section, Grid, Button, LabeledList } from "../components";
import { Window } from '../layouts';

export const ResearchChemConsumer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beaker_loaded,
    target_reagent,
    points_per_unit,
    required_amount,
    beaker_contents,
  } = data;
  return (
    <Window>
      <Window.Content scrollable>
        <Grid>
          <Grid.Column>
            <Section title="Status">
              <LabeledList>
                <LabeledList.Item label="Reagent Target">
                  {target_reagent}
                </LabeledList.Item>
                <LabeledList.Item label="Points:Units Ratio">
                  {points_per_unit}
                </LabeledList.Item>
              </LabeledList>
              <Button
                mt={1}
                fluid
                content={
                  "Consume " + required_amount + "u for " + (points_per_unit * required_amount) + " Points"
                }
                disabled={!(required_amount > 0)}
                onClick={
                  () => act('consume')
                } />
            </Section>
          </Grid.Column>
          <Grid.Column>
            <Section title="Beaker Contents" buttons={
              <Button
                disabled={!beaker_loaded}
                content="Eject Beaker"
                icon="eject"
                onClick={
                  () => act('eject_beaker')
                } />
            }>
              <LabeledList>
                {beaker_contents && (
                  beaker_contents.map(r => (
                    <LabeledList.Item key={r.name} label={r.name}>
                      {r.volume}
                    </LabeledList.Item>
                  ))
                )}
              </LabeledList>
            </Section>
          </Grid.Column>
        </Grid>
      </Window.Content>
    </Window>
  );
};
