import { Button, Dropdown, LabeledList, NoticeBox, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ComplexModal, modalRegisterBodyOverride } from '../common/ComplexModal';
import { addItemModal } from './modals';
import { ERTAugmentsPanel, ERTBackpackPanel, ERTLoadoutPanel } from './slot_panels';
import { AllowedItems, ERTLoadout, ERTLoadoutManagerData } from './types';

const ERTLoadoutManagerTabs = (props: { tabIndex: number }) => {
  const { act } = useBackend();
  const { tabIndex } = props;

  return (
    <Tabs>
      <Tabs.Tab selected={tabIndex === 0} onClick={() => act('set_tab', { tab: 0 })} key="loadout_slots" icon="shirt">
        Loadout Slots
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 1} onClick={() => act('set_tab', { tab: 1 })} key="backpack" icon="briefcase">
        Backpack Contents
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 2} onClick={() => act('set_tab', { tab: 2 })} key="augmentations" icon="syringe">
        Implants
      </Tabs.Tab>
    </Tabs>
  );
};

const ERTLoadoutManagerContent = (props: { allowedItems: AllowedItems; loadout: ERTLoadout; tabIndex: number }) => {
  const { allowedItems, loadout, tabIndex } = props;

  return (
    <>
      {tabIndex === 0 && <ERTLoadoutPanel loadout={loadout} allowedItems={allowedItems} />}
      {tabIndex === 1 && <ERTBackpackPanel loadout={loadout} />}
      {tabIndex === 2 && <ERTAugmentsPanel loadout={loadout} allowedItems={allowedItems} />}
    </>
  );
};

export const ERTLoadoutManager = () => {
  const { act, data } = useBackend<ERTLoadoutManagerData>();
  const { loadouts, allowed_items, selected_loadout, loadout_roles, tabIndex } = data;

  return (
    <Window width={650} height={650}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox>
              This interface is a Work in Progress. It is not wired up to the ERT deployment system yet.
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <Section
              title="Loadout"
              buttons={
                <>
                  <Button onClick={() => act('export_loadout')}>Export to JSON</Button>
                  <Button onClick={() => act('import_loadout')}>Import from JSON</Button>
                  <Button onClick={() => act('copy_to_new_loadout')}>Copy to New Loadout</Button>
                </>
              }
            >
              <Stack>
                <Stack.Item grow>
                  <LabeledList>
                    <LabeledList.Item label="Select Loadout">
                      <Dropdown
                        options={loadouts
                          .map((loadout) => loadout.loadout_name)
                          .filter((name) => name !== selected_loadout.loadout_name)}
                        onSelected={(val) => act('set_selected_loadout', { loadout_name: val })}
                        selected={selected_loadout.loadout_name}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Loadout Role">
                      <Dropdown
                        color={`role-${selected_loadout.loadout_role}`}
                        disabled={!!selected_loadout.frozen}
                        options={loadout_roles}
                        onSelected={(val) => act('set_loadout_role', { loadout_role: val })}
                        selected={selected_loadout.loadout_role}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <ERTLoadoutManagerTabs tabIndex={tabIndex} />
            <ERTLoadoutManagerContent allowedItems={allowed_items} loadout={selected_loadout} tabIndex={tabIndex} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

modalRegisterBodyOverride('open_add_item_modal', addItemModal);
