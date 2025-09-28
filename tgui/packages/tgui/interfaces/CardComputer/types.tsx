import { BooleanLike } from 'tgui-core/react';

export type CardSkin = {
  display_name: string;
  skin: string;
};

export type IdCard = {
  name: string;
  rank: string;
  registered_name: string;
  assignment: string;
  current_skin: string;
  current_skin_name: string;
  lastlog: string;
  associated_account_number: number;
  access: number[];
};

export type JobNames = {
  top: string[];
  assistant: string[];
  medical: string[];
  engineering: string[];
  science: string[];
  security: string[];
  service: string[];
  supply: string[];
  centcom: string[];
};

export type DepartmentPerson = {
  buttontext: string;
  crimstat: string;
  demotable: BooleanLike;
  name: string;
  title: string;
};

export type JobSlotData = {
  title: string;
  is_priority: BooleanLike;
  current_positions: number;
  total_positions: number;
  can_close: BooleanLike;
  can_open: BooleanLike;
  can_prioritize: BooleanLike;
};

export type CardComputerRecord = {
  transferee: string;
  oldvalue: string;
  newvalue: string;
  whodidit: string;
  timestamp: string;
  reason?: string;
  deletedby?: string;
};
