import { Stack } from 'tgui-core/components';

import { Window } from '../layouts';
import { ChooseAccess } from './AirlockElectronics';

export const ObjAccessModifier = () => {
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
