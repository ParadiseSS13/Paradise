import { Box, Button, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { routingError } from '../routes';

const RequirePDAInterface = require.context('./pda', false, /\.jsx$/);

const GetApp = (name) => {
  let appModule;
  try {
    appModule = RequirePDAInterface(`./${name}.jsx`);
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

export const PDA = (props) => {
  const { act, data } = useBackend();
  const { app, owner } = data;
  if (!owner) {
    return (
      <Window width={350} height={105}>
        <Window.Content scrollable>
          <Section title="Error">No user data found. Please swipe an ID card.</Section>
        </Window.Content>
      </Window>
    );
  }

  const App = GetApp(app.template);

  return (
    <Window width={600} height={650}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <PDAHeader />
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              p={1}
              pb={0}
              title={
                <Box>
                  <Icon name={app.icon} mr={1} />
                  {app.name}
                </Box>
              }
            >
              <App />
            </Section>
          </Stack.Item>
          <Stack.Item mt={7.5}>
            <PDAFooter />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PDAHeader = (props) => {
  const { act, data } = useBackend();
  const { idInserted, idLink, stationTime, cartridge_name } = data;

  return (
    <Stack fill>
      <Stack.Item ml={0.5}>
        <Button
          icon="id-card"
          color="transparent"
          onClick={() => act('Authenticate')}
          content={idInserted ? idLink : 'No ID Inserted'}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="sd-card"
          color="transparent"
          onClick={() => act('Eject')}
          content={cartridge_name ? ['Eject ' + cartridge_name] : 'No Cartridge Inserted'}
        />
      </Stack.Item>
      <Stack.Item grow textAlign="right" bold mr={1} mt={0.5}>
        {stationTime}
      </Stack.Item>
    </Stack>
  );
};

const PDAFooter = (props) => {
  const { act, data } = useBackend();

  const { app } = data;

  return (
    <Box height="45px" className="PDA__footer" backgroundColor="#1b1b1b">
      <Stack fill>
        {!!app.has_back && (
          <Stack.Item basis="33%" mr={-0.5}>
            <Button
              fluid
              className="PDA__footer__button"
              color="transparent"
              iconColor={app.has_back ? 'white' : 'disabled'}
              icon="arrow-alt-circle-left-o"
              onClick={() => act('Back')}
            />
          </Stack.Item>
        )}
        <Stack.Item basis={app.has_back ? '33%' : '100%'}>
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
