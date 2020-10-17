import { useBackend } from "../../backend";
import { Box, Button, Flex, LabeledList, Section } from "../../components";
import { RndRoute, RndNavButton } from "./index";
import { MENU, SUBMENU } from "../RndConsole";

export const SettingsMenu = (properties, context) => {
  const { data, act } = useBackend(context);

  const {
    sync,
    admin,
    linked_destroy,
    linked_lathe,
    linked_imprinter,
  } = data;

  return (
    <Box>
      <RndRoute submenu={SUBMENU.MAIN} render={() => (
        <Section title="Settings">
          <Flex direction="column" align="flex-start">
            <Button
              content="Sync Database with Network"
              icon="sync"
              disabled={!sync}
              onClick={() => {
                act('sync');
              }} />

            <Button
              content="Connect to Research Network"
              icon="plug"
              disabled={sync}
              onClick={() => {
                act('togglesync');
              }} />

            <Button
              disabled={!sync}
              icon="unlink"
              content="Disconnect from Research Network"
              onClick={() => {
                act('togglesync');
              }} />

            <RndNavButton
              disabled={!sync}
              content="Device Linkage Menu"
              icon="link"
              menu={MENU.SETTINGS} submenu={SUBMENU.SETTINGS_DEVICES}
            />

            {admin === 1 ? (
              <Button
                icon="exclamation"
                content="[ADMIN] Maximize Research Levels"
                onClick={() => act('maxresearch')} />
            ) : null}
          </Flex>
        </Section>
      )} />

      <RndRoute submenu={SUBMENU.SETTINGS_DEVICES} render={() => (
        <Section title="Device Linkage Menu">
          <Button
            icon="link"
            content="Re-sync with Nearby Devices"
            onClick={() => act('find_device')} />

          <Box mt="5px">
            <h3>Linked Devices:</h3>
          </Box>
          <LabeledList>

            {linked_destroy ? (
              <LabeledList.Item label="* Destructive Analyzer">
                <Button
                  icon="unlink"
                  content="Unlink"
                  onClick={() => act('disconnect', { item: 'destroy' })} />
              </LabeledList.Item>
            ) : (
              <LabeledList.Item noColon label="* No Destructive Analyzer Linked" />
            )}

            {linked_lathe ? (
              <LabeledList.Item label="* Protolathe">
                <Button
                  icon="unlink"
                  content="Unlink"
                  onClick={() => {
                    act('disconnect', { item: 'lathe' });
                  }} />
              </LabeledList.Item>
            ) : (
              <LabeledList.Item noColon label="* No Protolathe Linked" />
            )}

            {linked_imprinter ? (
              <LabeledList.Item label="* Circuit Imprinter">
                <Button
                  icon="unlink"
                  content="Unlink"
                  onClick={() => act('disconnect', { item: 'imprinter' })} />
              </LabeledList.Item>
            ) : (
              <LabeledList.Item noColon label="* No Circuit Imprinter Linked" />
            )}

          </LabeledList>
        </Section>
      )} />
    </Box>
  );
};
