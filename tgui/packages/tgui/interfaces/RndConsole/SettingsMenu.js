import { useBackend } from '../../backend';
import { Box, Button, Flex, LabeledList, Section } from '../../components';

export const SettingsMenu = (props, context) => (
  <Box>
    <MainSettings />
    <DeviceSettings />
  </Box>
);

const MainSettings = (props, context) => {
  const { act, data } = useBackend(context);
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
      </Flex>
    </Section>
  );
};

const DeviceSettings = (props, context) => {
  const { data, act } = useBackend(context);
  const { linked_destroy, linked_lathe, linked_imprinter } = data;

  return (
    <Section
      title="Linked Devices"
      buttons={<Button icon="link" content="Re-sync with Nearby Devices" onClick={() => act('find_device')} />}
    >
      <LabeledList>
        <LabeledList.Item label="Destructive Analyzer">
          <Button
            icon="unlink"
            disabled={!linked_destroy}
            content={linked_destroy ? 'Unlink' : 'Undetected'}
            onClick={() => act('disconnect', { item: 'destroy' })}
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
