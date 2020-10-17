import { useBackend } from "../backend";
import { Button, Box, Section, Flex, Icon } from "../components";
import { Window } from "../layouts";

/* This is all basically stolen from routes.js. */
import { routingError } from "../routes";

const RequirePAIInterface = require.context('./pai', false, /\.js$/);

const GetApp = name => {
  let appModule;
  try {
    appModule = RequirePAIInterface(`./${name}.js`);
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

export const PAI = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    app_template,
    app_icon,
    app_title,
  } = data;

  const App = GetApp(app_template);

  return (
    <Window>
      <Window.Content scrollable>
        <Section
          title={
            <Box>
              <Icon name={app_icon} mr={1} />
              {app_title}
              {app_template !== "pai_main_menu" && (
                <Button ml={2} content="Home" icon="arrow-up" onClick={
                  () => act('MASTER_back')
                } />
              )}
            </Box>
          }
          p={1}>
          <App />
        </Section>
      </Window.Content>
    </Window>
  );
};
