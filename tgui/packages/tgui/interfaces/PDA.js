import { useBackend } from '../backend';
import { Button, Box, Section, Stack, Icon } from '../components';
import { Window } from '../layouts';

/* This is all basically stolen from routes.js. */
import { routingError } from '../routes';

const RequirePDAInterface = require.context('./pda', false, /\.js$/);

const GetApp = (name) => {
  let appModule;
  try {
    appModule = RequirePDAInterface(`./${name}.js`);
  } catch (err) {
    if (err.code === 'MODULE_NOT_FOUND') {
      return routingError('notFound', name);
    }
    throw err;
  }
  const Component = appModule[name];
  if (!Component) {
    return routingError('missingExport', name);
  }
  return Component;
};

export const PDA = (props, context) => {
  const { act, data } = useBackend(context);
  const { app, owner } = data;
  if (!owner) {
    return (
      <Window width={600} height={650}>
        <Window.Content scrollable>
          <Section title="Error">
            No user data found. Please swipe an ID card.
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const App = GetApp(app.template);

  return (
    <Window>
      <Window.Content scrollable>
        <PDAHeader />
        <Section
          title={
            <Box>
              <Icon name={app.icon} mr={1} />
              {app.name}
            </Box>
          }
          p={1}
        >
          <App />
        </Section>
        <Box mb={8} />
        <PDAFooter />
      </Window.Content>
    </Window>
  );
};

const PDAHeader = (props, context) => {
  const { act, data } = useBackend(context);
  const { idInserted, idLink, stationTime, cartridge_name } = data;

  return (
    <Box mb={1}>
      <Stack align="center" justify="space-between">
        {idInserted ? (
          <Stack.Item>
            <Button
              icon="id-card"
              color="transparent"
              onClick={() => act('Authenticate')}
              content={idLink}
            />
          </Stack.Item>
        ) : (
          <Stack.Item m={1} color="grey">
            No ID Inserted
          </Stack.Item>
        )}

        {cartridge_name ? (
          <Stack.Item>
            <Button
              icon="sd-card"
              color="transparent"
              onClick={() => act('Eject')}
              content={'Eject ' + cartridge_name}
            />
          </Stack.Item>
        ) : (
          <Stack.Item m={1} color="grey">
            No Cartridge Inserted
          </Stack.Item>
        )}

        <Stack.Item grow textAlign="right" bold m={1}>
          {stationTime}
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const PDAFooter = (props, context) => {
  const { act, data } = useBackend(context);

  const { app } = data;

  return (
    <Box height="45px" className="PDA__footer" backgroundColor="#1b1b1b">
      <Stack>
        <Stack.Item basis="33%">
          <Button
            fluid
            className="PDA__footer__button"
            color="transparent"
            iconColor={app.has_back ? 'white' : 'disabled'}
            icon="arrow-alt-circle-left-o"
            onClick={() => act('Back')}
          />
        </Stack.Item>
        <Stack.Item basis="33%">
          <Button
            fluid
            className="PDA__footer__button"
            color="transparent"
            iconColor={app.is_home ? 'disabled' : 'white'}
            icon="home"
            onClick={() => {
              act('Home');
            }}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};
