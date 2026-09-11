import { useState } from 'react';
import { Button, Dropdown, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { itemsToDropdownEntries } from './slot_panels';
import { ERTLoadoutManagerData, ERTLoadoutSlot } from './types';

type Modal = {
  id: string;
  text: string;
  type: string;
  args: { slot: ERTLoadoutSlot };
};

export const addItemModal = (modal: Modal) => {
  const { data, act } = useBackend<ERTLoadoutManagerData>();
  const { allowed_items, selected_loadout } = data;
  const [selectedItem, setSelectedItem] = useState<string | null>(null);
  const [pathText, setPathText] = useState<string>('');

  const entries = itemsToDropdownEntries(allowed_items[selected_loadout.backpack_contents.slot_type]);
  const slot = modal.args.slot;

  return (
    <Section title={`Add ${slot.name} Item`}>
      <Stack vertical>
        <Stack.Item>Select an item from the below list, or enter an exact typepath.</Stack.Item>
        <Stack.Item>
          <Dropdown
            options={entries}
            selected={selectedItem}
            displayText={entries.find((e) => e.value === selectedItem)?.displayText}
            onSelected={(val) => {
              setPathText(val);
              setSelectedItem(val);
            }}
          />
        </Stack.Item>
        <Stack.Item>
          <Input width="100%" value={pathText} onChange={(val) => setPathText(val)} />
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => act('add_item_into_slot', { item_type: pathText, slot_uid: slot.uid })}>
            Add Item
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
