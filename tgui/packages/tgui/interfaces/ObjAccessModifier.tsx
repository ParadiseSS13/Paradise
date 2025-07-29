import { Button, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AccessList, AccessRegion } from './common/AccessList';
import { ChooseAccess } from './AirlockElectronics';

export const ObjAccessModifier = (props) => {
  return (
    <Window width={500} height={565}>
      <Window.Content>
        <Stack fill vertical>
          <ChooseAccess />
        </Stack>
      </Window.Content>
    </Window>
  );
};

