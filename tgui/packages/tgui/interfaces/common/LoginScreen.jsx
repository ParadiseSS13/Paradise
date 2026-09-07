import { Box, Button, Flex, Icon, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';

/**
 * Displays a login screen that users can interact with
 * using an ID card in their hand.
 * Required data fields:
 * * `loginState` — The current login state
 * * `isAI` — Whether the user is an AI. If true, shows "Login as AI"
 * * `isRobot` — Whether the user is a robot. If true, shows "Login as Cyborg"
 * * `isAdmin` — Whether the user is an admin. If true, shows
 *               "Secure CentComm Login"
 *
 * Clicking the main button calls the `login_insert` TGUI act.
 * Clicking either the AI or normal login button calls
 * the `login_login` TGUI act with a `login_type` parameter:
 * * 1 (LOGIN_TYPE_NORMAL) if it's an ID login
 * * 2 (LOGIN_TYPE_AI) if it's an AI login
 * * 3 (LOGIN_TYPE_ROBOT) if it's a robot login
 * * 4 (LOGIN_TYPE_ADMIN) if it's an admin login
 *
 * You will have to handle the AI login case in the same action.
 * The normal login button is only available when `loginState.id` is not null.
 * The AI, robot and admin login buttons are only visible if the user is one
 * @param {object} _properties
 */
export const LoginScreen = (_properties) => {
  const { act, data } = useBackend();
  const { loginState, isAI, isRobot, isAdmin } = data;
  return (
    <Section title="Welcome" fill stretchContents>
      <Flex height="100%" align="center" justify="center">
        <Flex.Item textAlign="center" mt="-2rem">
          <Box fontSize="1.5rem" bold>
            <Icon name="user-circle" verticalAlign="middle" size={3} mr="1rem" />
            Guest
          </Box>
          <Box color="label" my="1rem">
            ID:
            <Button
              icon="id-card"
              content={loginState.id ? loginState.id : '----------'}
              ml="0.5rem"
              onClick={() => act('login_insert')}
            />
          </Box>
          <Button
            icon="sign-in-alt"
            disabled={!loginState.id}
            content="Login"
            onClick={() =>
              act('login_login', {
                login_type: 1,
              })
            }
          />
          {!!isAI && (
            <Button
              icon="sign-in-alt"
              content="Login as AI"
              onClick={() =>
                act('login_login', {
                  login_type: 2,
                })
              }
            />
          )}
          {!!isRobot && (
            <Button
              icon="sign-in-alt"
              content="Login as Cyborg"
              onClick={() =>
                act('login_login', {
                  login_type: 3,
                })
              }
            />
          )}
          {!!isAdmin && (
            <Button
              icon="sign-in-alt"
              content="CentComm Secure Login"
              onClick={() =>
                act('login_login', {
                  login_type: 4,
                })
              }
            />
          )}
        </Flex.Item>
      </Flex>
    </Section>
  );
};
