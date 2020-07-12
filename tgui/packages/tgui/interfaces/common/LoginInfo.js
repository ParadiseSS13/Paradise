import { useBackend } from '../../backend';
import { Box, Button, NoticeBox } from '../../components';

/**
 * Displays a notice box showing the `scan` data field if it exists.
 *
 * Also gives an option to log off (calls `logout` TGUI action)
 * @param {object} _properties
 * @param {object} context
 */
export const LoginInfo = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    scan,
  } = data;
  if (!data) {
    return;
  }
  return (
    <NoticeBox info>
      <Box display="inline-block" verticalAlign="middle">
        Logged in as: {scan}
      </Box>
      <Button
        icon="sign-out-alt"
        content="Logout and Eject ID"
        color="good"
        float="right"
        onClick={() => act('logout')}
      />
      <Box clear="both" />
    </NoticeBox>
  );
};
