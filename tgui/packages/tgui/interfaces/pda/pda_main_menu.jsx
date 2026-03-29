import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const pda_main_menu = (props) => {
  const { act, data } = useBackend();

  const { owner, ownjob, idInserted, categories, pai, notifying } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Owner" color="average">
              {owner}, {ownjob}
            </LabeledList.Item>
            <LabeledList.Item label="ID">
              <Button icon="sync" content="Update PDA Info" disabled={!idInserted} onClick={() => act('UpdateInfo')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Functions">
          <LabeledList>
            {categories.map((name) => {
              let apps = data.apps[name];

              if (!apps || !apps.length) {
                return null;
              } else {
                return (
                  <LabeledList.Item label={name} key={name}>
                    {apps.map((app) => (
                      <Button
                        key={app.uid}
                        icon={app.uid in notifying ? app.notify_icon : app.icon}
                        iconSpin={app.uid in notifying}
                        color={app.uid in notifying ? 'red' : 'transparent'}
                        content={app.name}
                        onClick={() => act('StartProgram', { program: app.uid })}
                      />
                    ))}
                  </LabeledList.Item>
                );
              }
            })}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        {!!pai && (
          <Section title="pAI">
            <Button fluid icon="cog" content="Configuration" onClick={() => act('pai', { option: 1 })} />
            <Button fluid icon="eject" content="Eject pAI" onClick={() => act('pai', { option: 2 })} />
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
};
