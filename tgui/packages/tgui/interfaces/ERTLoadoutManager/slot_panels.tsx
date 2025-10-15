import { Box, Button, Dropdown, LabeledList, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { modalOpen } from '../common/ComplexModal';
import { AllowedItems, DropdownEntry, ERTItem, ERTLoadout, ERTLoadoutSingleSlot } from './types';

const itemToDropdownEntry = (item: ERTItem | undefined): DropdownEntry => {
  return item ? { displayText: item.item_name, value: item.item_type } : { displayText: 'None', value: '' };
};

export const itemsToDropdownEntries = (items: ERTItem[]): DropdownEntry[] => {
  return items.map((item) => itemToDropdownEntry(item));
};

export const ERTLoadoutSingleSlotPanel = (props: {
  loadout: ERTLoadout;
  slot: ERTLoadoutSingleSlot;
  allowed: AllowedItems;
}) => {
  const { act } = useBackend();
  const { loadout, slot, allowed } = props;
  const entries = itemsToDropdownEntries(allowed[slot.slot_type]);

  return (
    <LabeledList.Item label={slot.name}>
      <Stack>
        <Stack.Item grow>
          <Dropdown
            disabled={!!loadout.frozen}
            options={entries}
            selected={slot.chosen_item}
            displayText={entries.find((e) => e.value === slot.chosen_item)?.displayText}
            onSelected={(val) => {
              act('set_single_slot', { slot_uid: slot.uid, item_type: val });
            }}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={!!loadout.frozen}
            icon="plus"
            onClick={() => modalOpen('open_add_item_modal', { slot: slot })}
          >
            New Item...
          </Button>
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};

export const ERTBackpackPanel = (props: { loadout: ERTLoadout }) => {
  const { loadout } = props;
  const { act } = useBackend();

  return (
    <Section
      title="Backpack Contents"
      buttons={
        <>
          <Button
            icon="trash"
            disabled={!!loadout.frozen || Object.keys(loadout.backpack_contents.chosen_item_quantities).length === 0}
            onClick={() => act('empty_backpack')}
          >
            Empty
          </Button>
          <Button
            disabled={!!loadout.frozen}
            icon="plus"
            onClick={() => modalOpen('open_add_item_modal', { slot: loadout.backpack_contents })}
          >
            Add Item...
          </Button>
        </>
      }
    >
      <Table>
        {Object.keys(loadout.backpack_contents.chosen_item_quantities).map((item) => (
          <Table.Row className="candystripe" key={item} textAlign="right">
            <Table.Cell>{loadout.backpack_contents.chosen_item_names[item]}</Table.Cell>
            <Table.Cell align="right">
              <Box as="span">
                <Button
                  disabled={!!loadout.frozen}
                  icon={loadout.backpack_contents.chosen_item_quantities[item] > 1 ? 'minus' : 'trash'}
                  textAlign="center"
                  onClick={() => act('decrement_backpack_item', { item_type: item })}
                />
                <code> {loadout.backpack_contents.chosen_item_quantities[item]} </code>
                <Button
                  disabled={!!loadout.frozen}
                  icon="plus"
                  textAlign="center"
                  onClick={() => act('increment_backpack_item', { item_type: item })}
                />
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

export const ERTAugmentsPanel = (props: { allowedItems: AllowedItems; loadout: ERTLoadout }) => {
  const { allowedItems: allowed_items, loadout } = props;
  const { act } = useBackend();

  return (
    <Stack scrollable>
      <Stack.Item grow>
        <Section title="Cybernetic Implants">
          <Stack vertical>
            {allowed_items[loadout.cybernetic_implants.slot_type].map((item) => (
              <Stack.Item key={item.item_type}>
                <Button.Checkbox
                  disabled={!!loadout.frozen}
                  checked={!!loadout.cybernetic_implants.chosen_items.find((chosen) => chosen === item.item_type)}
                  key={item.item_type}
                  onClick={() => act('toggle_implant', { implant_type: item.item_type })}
                >
                  {item.item_name}
                </Button.Checkbox>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Bio-Chips">
          <Stack vertical>
            {allowed_items[loadout.bio_chips.slot_type].map((item) => (
              <Stack.Item key={item.item_type}>
                <Button.Checkbox
                  disabled={!!loadout.frozen}
                  checked={!!loadout.bio_chips.chosen_items.find((chosen) => chosen === item.item_type)}
                  onClick={() => act('toggle_biochip', { biochip_type: item.item_type })}
                >
                  {item.item_name}
                </Button.Checkbox>
                <br />
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const ERTLoadoutPanel = (props: { loadout: ERTLoadout; allowedItems: AllowedItems }) => {
  const { loadout, allowedItems: allowed_items } = props;

  return (
    <Section title="Loadout Slots">
      <LabeledList>
        <ERTLoadoutSingleSlotPanel loadout={loadout} allowed={allowed_items} slot={loadout.primary_firearm} />
        <ERTLoadoutSingleSlotPanel loadout={loadout} allowed={allowed_items} slot={loadout.secondary_firearm} />
        <ERTLoadoutSingleSlotPanel loadout={loadout} allowed={allowed_items} slot={loadout.head} />
        <ERTLoadoutSingleSlotPanel loadout={loadout} allowed={allowed_items} slot={loadout.glasses} />
        <ERTLoadoutSingleSlotPanel loadout={loadout} allowed={allowed_items} slot={loadout.mask} />
        <ERTLoadoutSingleSlotPanel loadout={loadout} allowed={allowed_items} slot={loadout.back} />
        <ERTLoadoutSingleSlotPanel loadout={loadout} allowed={allowed_items} slot={loadout.belt} />
        <ERTLoadoutSingleSlotPanel loadout={loadout} allowed={allowed_items} slot={loadout.l_pocket} />
        <ERTLoadoutSingleSlotPanel loadout={loadout} allowed={allowed_items} slot={loadout.r_pocket} />
        <ERTLoadoutSingleSlotPanel loadout={loadout} allowed={allowed_items} slot={loadout.shoes} />
      </LabeledList>
    </Section>
  );
};
