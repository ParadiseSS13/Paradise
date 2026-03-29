import { Box, Button, Flex, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const SettingsMenu = (props) => (
  <Box>
    <MainSettings />
    <DeviceSettings />
  </Box>
);

const MainSettings = (props) => {
  const { act, data } = useBackend();
  const { sync, admin } = data;

  return (
    <Section title="Settings">
      <Flex direction="column" align="flex-start">
        <Button
          color="red"
          icon="unlink"
          content="Disconnect from Research Network"
          onClick={() => {
            act('unlink');
          }}
        />
        {admin === 1 ? (
          <Button
            icon="gears"
            color="red"
            content="[ADMIN] Maximize research levels"
            onClick={() => act('maxresearch')}
          />
        ) : null}
      </Flex>
    </Section>
  );
};

const DeviceSettings = (props) => {
  const { data, act } = useBackend();
  const { linked_analyzer, linked_lathe, linked_imprinter } = data;

  return (
    <Section
      title="Linked Devices"
      buttons={<Button icon="link" content="Re-sync with Nearby Devices" onClick={() => act('find_device')} />}
    >
      <LabeledList>
        <LabeledList.Item label="Scientific Analyzer">
          <Button
            icon="unlink"
            disabled={!linked_analyzer}
            content={linked_analyzer ? 'Unlink' : 'Undetected'}
            onClick={() => act('disconnect', { item: 'analyze' })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Protolathe">
          <Button
            icon="unlink"
            disabled={!linked_lathe}
            content={linked_lathe ? 'Unlink' : 'Undetected'}
            onClick={() => {
              act('disconnect', { item: 'lathe' });
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Circuit Imprinter">
          <Button
            icon="unlink"
            disabled={!linked_imprinter}
            content={linked_imprinter ? 'Unlink' : 'Undetected'}
            onClick={() => act('disconnect', { item: 'imprinter' })}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
