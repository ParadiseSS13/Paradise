import { Button, Stack } from 'tgui-core/components';

let url: string | null = null;

setInterval(() => {
  Byond.winget('', 'url').then((currentUrl) => {
    // Sometimes, for whatever reason, BYOND will give an IP with a :0 port.
    if (currentUrl && !currentUrl.match(/:0$/)) {
      url = currentUrl;
    }
  });
}, 5000);

export const ReconnectButton = () => {
  if (!url) {
    return null;
  }
  return (
    <Stack>
      <Stack.Item>
        <Button
          fluid
          icon="history"
          color="white"
          content="Reconnect"
          onClick={() => {
            Byond.command('.reconnect');
          }}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="power-off"
          color="white"
          tooltip="Restart game"
          tooltipPosition="bottom-end"
          onClick={() => {
            Byond.command('.quit');
          }}
        />
      </Stack.Item>
    </Stack>
  );
};
