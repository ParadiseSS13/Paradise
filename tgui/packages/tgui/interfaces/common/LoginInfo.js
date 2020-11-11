import { useBackend } from '../../backend';
import { Box, Button, NoticeBox } from '../../components';

/**
 * Displays a notice box displaying the current login state.
 *
 * Also gives an option to log off (calls `login_logout` TGUI action)
 * @param {object} _properties
 * @param {object} context
 */
export const LoginInfo = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    loginState,
  } = data;
  if (!data) {
    return;
  }
  return (
    <NoticeBox info>
      <Box display="inline-block" verticalAlign="middle">
        Logged in as: {loginState.name} ({loginState.rank})
      </Box>
      <Button
        icon="sign-out-alt"
        content="Logout"
        color="good"
        float="right"
        onClick={() => act('login_logout')}
      />
      <Button
        icon="sign-out-alt"
        disabled={!loginState.id}
        content="Eject ID"
        color="good"
        float="right"
        onClick={() => act('login_eject')}
      />
      <Box clear="both" />
    </NoticeBox>
  );
};
