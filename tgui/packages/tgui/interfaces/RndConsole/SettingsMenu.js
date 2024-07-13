import { useBackend } from '../../backend';
import { Box, Button, Flex, LabeledList, Section } from '../../components';

export const SettingsMenu = (properties, context) => {
  const { data, act } = useBackend(context);

  const { sync, admin, linked_destroy, linked_lathe, linked_imprinter } = data;

  return (
    <Box>
      <Section title="Settings">
        <Flex direction="column" align="flex-start">
          <Button
            content="Sync Database with Network"
            icon="sync"
            disabled={!sync}
            onClick={() => {
              act('sync');
            }}
          />

          <Button
            content="Connect to Research Network"
            icon="plug"
            disabled={sync}
            onClick={() => {
              act('togglesync');
            }}
          />

          <Button
            disabled={!sync}
            icon="unlink"
            content="Disconnect from Research Network"
            onClick={() => {
              act('togglesync');
            }}
          />

          {admin === 1 ? (
            <Button icon="exclamation" content="[ADMIN] Maximize Research Levels" onClick={() => act('maxresearch')} />
          ) : null}
        </Flex>
      </Section>

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
    </Box>
  );
};
