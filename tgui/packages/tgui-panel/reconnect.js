import { Button, Flex } from 'tgui/components';

export const ReconnectButton = (props, context) => {
  return (
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
          tooltipPosition="top-end"
          onClick={() => {
            Byond.command('.quit');
          }}
        />
      </Flex.Item>
    </Flex>
  );
};
