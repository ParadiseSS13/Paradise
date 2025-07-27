import { Box, Button, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { routingError } from '../routes';

const RequirePAIInterface = require.context('./pai', false, /\.jsx$/);

const GetApp = (name) => {
  let appModule;
  try {
    appModule = RequirePAIInterface(`./${name}.jsx`);
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

export const PAI = (props) => {
  const { act, data } = useBackend();
  const { app_template, app_icon, app_title } = data;

  const App = GetApp(app_template);

  return (
    <Window width={600} height={650}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              p={1}
              fill
              scrollable
              title={
                <Box>
                  <Icon name={app_icon} mr={1} />
                  {app_title}
                  {app_template !== 'pai_main_menu' && (
                    <>
                      <Button ml={2} mb={0} content="Back" icon="arrow-left" onClick={() => act('Back')} />
                      <Button content="Home" icon="arrow-up" onClick={() => act('MASTER_back')} />
                    </>
                  )}
                </Box>
              }
            >
              <App />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
