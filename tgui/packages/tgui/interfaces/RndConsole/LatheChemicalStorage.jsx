import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const LatheChemicalStorage = (properties) => {
  const { data, act } = useBackend();

  const { loaded_chemicals } = data;

  const lathe = data.menu === 4;

  return (
    <Section title="Chemical Storage">
      <Button
        content="Purge All"
        icon="trash"
        onClick={() => {
          const action = lathe ? 'disposeallP' : 'disposeallI';
          act(action);
        }}
      />

      <LabeledList>
        {loaded_chemicals.map(({ volume, name, id }) => (
          <LabeledList.Item label={`* ${volume} of ${name}`} key={id}>
            <Button
              content="Purge"
              icon="trash"
              onClick={() => {
                const action = lathe ? 'disposeP' : 'disposeI';
                act(action, { id });
              }}
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};
