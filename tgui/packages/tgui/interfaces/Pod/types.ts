import { BooleanLike } from 'tgui-core/react';

export type MainData = {
  isoperator: BooleanLike;
  name: string;
  integrity: number;
  integrity_max: number;
  power_level: number;
  power_max: number;
  mecha_flags: number;
  mechflag_keys: string[];
  dna_lock: string | null;
};
