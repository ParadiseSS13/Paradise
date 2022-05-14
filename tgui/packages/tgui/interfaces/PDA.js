import { useBackend } from "../backend";
import { Button, Box, Section, Flex, Icon } from "../components";
import { Window } from "../layouts";

/* This is all basically stolen from routes.js. */
import { routingError } from "../routes";

const RequirePDAInterface = require.context('./pda', false, /\.js$/);

const GetApp = name => {
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
  const {
    app,
    owner,
  } = data;
  if (!owner) {
    return (
      <Window>
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
          p={1}>
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
  const {
    idInserted,
    idLink,
    stationTime,
    cartridge_name,
  } = data;

  return (
    <Box mb={1}>
      <Flex align="center" justify="space-between">
        {idInserted ? (
          <Flex.Item>
            <Button
              icon="id-card"
              color="transparent"
              onClick={() => act("Authenticate")}
              content={idLink} />
          </Flex.Item>
        ) : (
          <Flex.Item m={1} color="grey">
            No ID Inserted
          </Flex.Item>
        )}

        {cartridge_name ? (
          <Flex.Item>
            <Button
              icon="sd-card"
              color="transparent"
              onClick={() => act("Eject")}
              content={"Eject " + cartridge_name} />
          </Flex.Item>
        ) : (
          <Flex.Item m={1} color="grey">
            No Cartridge Inserted
          </Flex.Item>
        )}

        <Flex.Item grow={1} textAlign="right" bold m={1}>
          {stationTime}
        </Flex.Item>
      </Flex>
    </Box>
  );
};


const PDAFooter = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    app,
  } = data;

  return (
    <Box className="PDA__footer" backgroundColor="#1b1b1b">
      <Flex>
        <Flex.Item basis="33%">
          <Button
            fluid
            className="PDA__footer__button"
            color="transparent"
            iconColor={app.has_back ? "white" : "disabled"}
            icon="arrow-alt-circle-left-o"
            onClick={() => act("Back")} />
        </Flex.Item>
        <Flex.Item basis="33%">
          <Button
            fluid
            className="PDA__footer__button"
            color="transparent"
            iconColor={app.is_home ? "disabled" : "white"}
            icon="home"
            onClick={() => { act("Home"); }} />
        </Flex.Item>
      </Flex>
    </Box>
  );
};
