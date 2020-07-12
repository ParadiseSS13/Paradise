import { useBackend } from '../../backend';
import { Box, Button, Flex, Icon, Section } from '../../components';

/**
 * Displays a login screen that users can interact with
 * using an ID card in their hand.
 * Requires a `scan` data field in the DM side, corresponding
 * to the name on the card.
 *
 * Clicking the main button calls the `scan` TGUI act.
 *
 * Clicking the login button calls the `login` TGUI act.
 * Only available when `scan` is not null
 * @param {object} _properties
 * @param {object} context
 */
export const LoginScreen = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    scan,
  } = data;
  return (
    <Section title="Welcome" height="100%" stretchContents>
      <Flex height="100%" align="center" justify="center">
        <Flex.Item textAlign="center" mt="-2rem">
          <Box fontSize="1.5rem" bold>
            <Icon
              name="user-circle"
              verticalAlign="middle"
              size={3}
              mr="1rem"
            />
            Guest
          </Box>
          <Box color="label" my="1rem">
            ID:
            <Button
              icon="id-card"
              content={scan ? scan : "----------"}
              ml="0.5rem"
              onClick={() => act('scan')}
            />
          </Box>
          <Button
            icon="sign-in-alt"
            disabled={!scan}
            content="Login"
            onClick={() => act('login')}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};
