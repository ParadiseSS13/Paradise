import { Button, Flex } from 'tgui/components';

let url = null;

setInterval(() => {
  Byond.winget('', 'url').then((currentUrl) => {
    // Sometimes, for whatever reason, BYOND will give an IP with a :0 port.
    if (currentUrl && !currentUrl.match(/:0$/)) {
      url = currentUrl;
    }
  });
}, 0);

export const ReconnectButton = (props, context) => {
  return (
    url && (
      <Flex>
        <Flex.Item mr="3px">
          <Button
            fluid
            icon="history"
            color="white"
            content="Reconnect"
            onClick={() => {
              Byond.command('.reconnect');
            }}
          />
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="power-off"
            color="white"
            tooltip="Restart game"
            tooltipPosition="top-left"
            onClick={() => {
              location.href = `byond://${url}`;
              Byond.command('.quit');
            }}
          />
        </Flex.Item>
      </Flex>
    )
  );
};
