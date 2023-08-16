import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const MedicalChemistryRecipes = (props, context) => {
  const { data } = useBackend(context);
  const { reagents = [], components = []} = data;
  const [ reagentIndex, setReagentIndex] = useLocalState(context, 'reagentIndex', 0);
  const [ reagentType, setReagentType] = useLocalState(context, 'reagentType', 0);

  let selected_reagent = reagents[reagentIndex]
  if(reagentType === 0) {
    selected_reagent = reagents[reagentIndex]
  }
  else {
    selected_reagent = components[reagentIndex]
  }

  // Todo: fix the iteration error I have no idea about, cannot build tgui.bundle.js until then
  return (
    <Window>
      <Window.Content>
        <Section title="Medicine">
          <Box>
              {reagents.map((medicine, id) => (
                <Button
                  key={id}
                  content={medicine.name}
                  textAlign="center"
                  selected={reagentType === 0 ? id === reagentIndex : null}
                  onClick={() => {setReagentIndex(id); setReagentType(0)}}
                />
              ))}
          </Box>
        </Section>

        <Section title="Components">
        <Box>
              {components.map((component, id) => (
                <Button
                  key={id}
                  content={component.name}
                  textAlign="center"
                  selected={reagentType === 1 ? id === reagentIndex : null}
                  onClick={() => {setReagentIndex(id); setReagentType(1)}}
                />
              ))}
          </Box>
        </Section>

        <Section title="Description">
          <LabeledList>
            <LabeledList.Item label = "Name">
            {selected_reagent.name}
            </LabeledList.Item>
            <LabeledList.Item label = "Description">
            {selected_reagent.description}
            </LabeledList.Item>
            <LabeledList.Item label = "Metabolization Rate">
            {selected_reagent.metabolization} units / cycle
            </LabeledList.Item>
            <LabeledList.Item label = "Overdose Threshold">
            {selected_reagent.overdose === 0 ? "None" : [selected_reagent.overdose] + " units"}
            </LabeledList.Item>
            <LabeledList.Item label = "Ingredients">
            {Object.entries(selected_reagent.reaction_components).sort().map(r => {
              return r[1] + " part " + r[0];
            }).join(', ')}
            </LabeledList.Item>
            <LabeledList.Item label = "Required Temperature">
            {selected_reagent.reaction_temperature === 0 ? "None" : [selected_reagent.reaction_temperature] + " K"}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
