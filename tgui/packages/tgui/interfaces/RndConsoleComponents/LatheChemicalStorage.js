import { useBackend } from "../../backend";
import { Button, LabeledList, Section } from "../../components";

export const LatheChemicalStorage = (properties, context) => {
  const { data, act } = useBackend(context);

  const {
    loaded_chemicals,
  } = data;

  const lathe = data.menu === 4;

  return (
    <Section title="Chemical Storage">

      <Button
        content="Purge All"
        icon="trash"
        onClick={() => {
          const action = lathe ? 'disposeallP' : 'disposeallI';
          act(action);
        }} />

      <LabeledList>
        {loaded_chemicals.map(({ volume, name, type }) => (
          <LabeledList.Item label={`* ${volume} of ${name}`} key={type}>
            <Button
              content="Purge"
              icon="trash"
              onClick={() => {
                const action = lathe ? 'disposeP' : 'disposeI';
                act(action, { type });
              }} />
          </LabeledList.Item>
        ))}
      </LabeledList>

    </Section>
  );
};
