import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section, Box } from '../components';
import { Window } from '../layouts';

export const CloningPod = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    biomass,
    biomass_storage_capacity,
    sanguine_reagent,
    osseous_reagent,
    organs
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Liquid Storage">
          <LabeledList>
            <LabeledList.Item label="Biomass">
              <ProgressBar
                value={biomass}
                ranges={{
                  good: [(2*biomass_storage_capacity)/3, biomass_storage_capacity],
                  average: [biomass_storage_capacity/3, (2*biomass_storage_capacity)/3],
                  bad: [0, biomass_storage_capacity/3] // This is just thirds
                }}
                minValue={0}
                maxValue={biomass_storage_capacity}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Sanguine Reagent">
              {sanguine_reagent + " units"}
            </LabeledList.Item>
            <LabeledList.Item label="Osseous Reagent">
              {osseous_reagent + " units"}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Organ Storage">
          {!organs && (<Box color='average'>Notice: No organs loaded.</Box>)}
          <LabeledList>
            {!!organs &&
              organs.map(organ => (
                  <LabeledList.Item
                    key={organ}
                    label="Name"
                    buttons={
                      <Button content='Eject' onClick={() => act('eject_organ', {organ_ref: organ.ref})}/>
                    }>
                  {organ.name}
                  </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
