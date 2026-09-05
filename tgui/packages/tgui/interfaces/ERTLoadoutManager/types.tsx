import { ReactNode } from 'react';
import { BooleanLike } from 'tgui-core/react';

export type AllowedItems = Record<string, ERTItem[]>;

export type ERTLoadoutSingleSlot = ERTLoadoutSlot & {
  chosen_item?: string;
};

export type ERTLoadoutMultipleSlot = ERTLoadoutSlot & {
  chosen_items: string[];
};

export type ERTLoadoutAssortedSlot = ERTLoadoutSlot & {
  chosen_item_quantities: Record<string, number>;
  chosen_item_names: Record<string, string>;
};

export type ERTLoadoutManagerData = {
  // static data
  loadouts: ERTLoadout[];
  allowed_items: AllowedItems;
  loadout_roles: string[];

  // local data
  tabIndex: number;
  selected_loadout: ERTLoadout;
};

export type ERTLoadout = {
  loadout_name: string;
  loadout_role: string;
  frozen: BooleanLike;

  primary_firearm: ERTLoadoutSingleSlot;
  secondary_firearm: ERTLoadoutSingleSlot;
  cybernetic_implants: ERTLoadoutMultipleSlot;
  bio_chips: ERTLoadoutMultipleSlot;
  backpack_contents: ERTLoadoutAssortedSlot;
  head: ERTLoadoutSingleSlot;
  shoes: ERTLoadoutSingleSlot;
  belt: ERTLoadoutSingleSlot;
  back: ERTLoadoutSingleSlot;
  glasses: ERTLoadoutSingleSlot;
  mask: ERTLoadoutSingleSlot;
  l_pocket: ERTLoadoutSingleSlot;
  r_pocket: ERTLoadoutSingleSlot;
  neck: ERTLoadoutSingleSlot;
};

export type ERTItemValues = 'item_name' | 'item_type';
export type ERTItem = Record<ERTItemValues, string>;

export type ERTLoadoutSlot = {
  name: string;
  slot_type: string;
  uid: string;
};

/* no clue why tgui doesn't expose this */
export type DropdownEntry = {
  displayText: ReactNode;
  value: string | number;
};
