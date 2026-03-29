import { Button, NoticeBox, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

/**
 * Displays a notice box with text and style dictated by the
 * `temp` data field if it exists.
 *
 * A valid `temp` object contains:
 *
 * - `style` — The style of the NoticeBox
 * - `text` — The text to display
 *
 * Allows clearing the notice through the `cleartemp` TGUI act
 * @param {object} _properties
 */
export const TemporaryNotice = (_properties) => {
  const { act, data } = useBackend();
  const { temp } = data;
  if (!temp) {
    return;
  }
  const temporaryProperty = { [temp.style]: true };
  return (
    <NoticeBox {...temporaryProperty}>
      <Stack>
        <Stack.Item grow mt={0.5}>
          {temp.text}
        </Stack.Item>
        <Stack.Item>
          <Button icon="times-circle" onClick={() => act('cleartemp')} />
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
};
