import { Box, Button, Flex } from '../../components';

import { useBackend } from '../../backend';

type InputButtonsData = {
  large_buttons: boolean;
  swapped_buttons: boolean;
};

type InputButtonsProps = {
  input: string | number | string[];
  message?: string;
  disabled?: boolean;
};

export const InputButtons = (props: InputButtonsProps, context) => {
  const { act, data } = useBackend<InputButtonsData>(context);
  const { large_buttons, swapped_buttons } = data;
  const { input, message, disabled } = props;
  const submitButton = (
    <Button
      color="good"
      content="Submit"
      bold={!!large_buttons}
      fluid={!!large_buttons}
      onClick={() => act('submit', { entry: input })}
      textAlign="center"
      tooltip={large_buttons && message}
      disabled={disabled}
      width={!large_buttons && 6}
    />
  );
  const cancelButton = (
    <Button
      color="bad"
      content="Cancel"
      bold={!!large_buttons}
      fluid={!!large_buttons}
      onClick={() => act('cancel')}
      textAlign="center"
      width={!large_buttons && 6}
    />
  );

  return (
    <Flex
      fill
      align="center"
      direction={!swapped_buttons ? 'row' : 'row-reverse'}
      justify="space-around"
    >
      {large_buttons ? (
        <Flex.Item
          grow
          ml={swapped_buttons ? 0.5 : 0}
          mr={!swapped_buttons ? 0.5 : 0}
        >
          {cancelButton}
        </Flex.Item>
      ) : (
        <Flex.Item>{cancelButton}</Flex.Item>
      )}
      {!large_buttons && message && (
        <Flex.Item>
          <Box color="label" textAlign="center">
            {message}
          </Box>
        </Flex.Item>
      )}
      {large_buttons ? (
        <Flex.Item
          grow
          mr={swapped_buttons ? 0.5 : 0}
          ml={!swapped_buttons ? 0.5 : 0}
        >
          {submitButton}
        </Flex.Item>
      ) : (
        <Flex.Item>{submitButton}</Flex.Item>
      )}
    </Flex>
  );
};
