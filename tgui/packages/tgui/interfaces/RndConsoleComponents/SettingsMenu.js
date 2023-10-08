import { useBackend } from '../../backend';
import { Box, Button, Flex, LabeledList, Section } from '../../components';
import { RndRoute, RndNavButton } from './index';
import { MENU, SUBMENU } from '../RndConsole';

export const SettingsMenu = (properties, context) => {
  const { data, act } = useBackend(context);

  const { admin, linked_analyzer, linked_lathe, linked_imprinter } = data;

  return (
    <Box>
      <RndRoute
        submenu={SUBMENU.MAIN}
        render={() => (
          <Section title="Settings">
            <Flex direction="column" align="flex-start">
              <RndNavButton
                content="Device Linkage Menu"
                icon="link"
                menu={MENU.SETTINGS}
                submenu={SUBMENU.SETTINGS_DEVICES}
              />

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
                  icon="exclamation"
                  content="[ADMIN] Maximize Research Levels"
                  onClick={() => act('maxresearch')}
                />
              ) : null}
            </Flex>
          </Section>
        )}
      />

      <RndRoute
        submenu={SUBMENU.SETTINGS_DEVICES}
        render={() => (
          <Section title="Device Linkage Menu">
            <Button
              icon="link"
              content="Re-sync with Nearby Devices"
              onClick={() => act('find_device')}
            />

            <Box mt="5px">
              <h3>Linked Devices:</h3>
            </Box>
            <LabeledList>
              {linked_analyzer ? (
                <LabeledList.Item label="* Science Analyzer">
                  <Button
                    icon="unlink"
                    content="Unlink"
                    onClick={() => act('disconnect', { item: 'analyzer' })}
                  />
                </LabeledList.Item>
              ) : (
                <LabeledList.Item
                  noColon
                  label="* No Science Analyzer Linked"
                />
              )}

              {linked_lathe ? (
                <LabeledList.Item label="* Protolathe">
                  <Button
                    icon="unlink"
                    content="Unlink"
                    onClick={() => {
                      act('disconnect', { item: 'lathe' });
                    }}
                  />
                </LabeledList.Item>
              ) : (
                <LabeledList.Item noColon label="* No Protolathe Linked" />
              )}

              {linked_imprinter ? (
                <LabeledList.Item label="* Circuit Imprinter">
                  <Button
                    icon="unlink"
                    content="Unlink"
                    onClick={() => act('disconnect', { item: 'imprinter' })}
                  />
                </LabeledList.Item>
              ) : (
                <LabeledList.Item
                  noColon
                  label="* No Circuit Imprinter Linked"
                />
              )}
            </LabeledList>
          </Section>
        )}
      />
    </Box>
  );
};
