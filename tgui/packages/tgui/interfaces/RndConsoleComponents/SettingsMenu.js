import { useBackend } from "../../backend";
import { Button, Flex, LabeledList, Section } from "../../components";
import { RndRoute, RndNavButton } from "./index";

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
    <div>
      <RndRoute submenu={0} render={() => (
        <Section title="Settings">
          <Flex direction="column" align="flex-start">
            <Button
              disabled={!sync}
              onClick={() => {
                act('sync');
              }}>
              <i className="fa fa-sync" />
              Sync Database with Network
            </Button>

            <Button
              disabled={sync}
              onClick={() => {
                act('togglesync');
              }}>
              <i className="fa fa-plug" />
              Connect to Research Network
            </Button>

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
              menu={6} submenu={1}
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

      <RndRoute submenu={1} render={() => (
        <Section title="Device Linkage Menu">
          <Button
            icon="link"
            content="Re-sync with Nearby Devices"
            onClick={() => act('find_device')} />

          <h3 style={{ 'margin-top': '5px' }}>Linked Devices:</h3>
          <LabeledList>

            {linked_destroy ? (
              <LabeledList.Item labelColor="yellow" label="* Destructive Analyzer">
                <Button
                  icon="unlink"
                  content="Unlink"
                  onClick={() => act('disconnect', { item: 'destroy' })} />
              </LabeledList.Item>
            ) : (
              <LabeledList.Item noColon labelColor="yellow" label="* No Destructive Analyzer Linked" />
            )}

            {linked_lathe ? (
              <LabeledList.Item labelColor="yellow" label="* Protolathe">
                <Button
                  icon="unlink"
                  content="Unlink"
                  onClick={() => {
                    act('disconnect', { item: 'lathe' });
                  }} />
              </LabeledList.Item>
            ) : (
              <LabeledList.Item noColon labelColor="yellow" label="* No Protolathe Linked" />
            )}

            {linked_imprinter ? (
              <LabeledList.Item labelColor="yellow" label="* Circuit Imprinter">
                <Button
                  icon="unlink"
                  content="Unlink"
                  onClick={() => act('disconnect', { item: 'imprinter' })} />
              </LabeledList.Item>
            ) : (
              <LabeledList.Item noColon labelColor="yellow" label="* No Circuit Imprinter Linked" />
            )}

          </LabeledList>
        </Section>
      )} />
    </div>
  );
};
