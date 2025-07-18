import { Button, NoticeBox, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

/**
 * Displays a notice box displaying the current login state.
 *
 * Also gives an option to log off (calls `login_logout` TGUI action)
 * @param {object} _properties
 */
export const LoginInfo = (_properties) => {
  const { act, data } = useBackend();
  const { loginState } = data;
  if (!data) {
    return;
  }
  return (
    <NoticeBox info>
      <Stack>
        <Stack.Item grow mt={0.5}>
          Logged in as: {loginState.name} ({loginState.rank})
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="eject"
            disabled={!loginState.id}
            content="Eject ID"
            color="good"
            onClick={() => act('login_eject')}
          />
          <Button icon="sign-out-alt" content="Logout" color="good" onClick={() => act('login_logout')} />
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
};
