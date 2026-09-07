import { Box, Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

type InputButtonsData = {
  large_buttons: boolean;
  swapped_buttons: boolean;
};

type InputButtonsProps = {
  input: string | number | string[] | Object;
  message?: string;
  disabled?: boolean;
};

export const InputButtons = (props: InputButtonsProps) => {
  const { act, data } = useBackend<InputButtonsData>();
  const { large_buttons, swapped_buttons } = data;
  const { input, message, disabled } = props;
  const submitButton = (
    <Button
      color="good"
      textAlign="center"
      bold={!!large_buttons}
      fluid={!!large_buttons}
      tooltip={!!large_buttons && message}
      disabled={!!disabled}
      width={!large_buttons && 6}
      onClick={() => act('submit', { entry: input })}
    >
      Submit
    </Button>
  );
  const cancelButton = (
    <Button
      color="bad"
      textAlign="center"
      bold={!!large_buttons}
      fluid={!!large_buttons}
      width={!large_buttons && 6}
      onClick={() => act('cancel')}
    >
      Cancel
    </Button>
  );

  return (
    <Stack fill align="center" direction={!swapped_buttons ? 'row' : 'row-reverse'} justify="space-around">
      <Stack.Item grow={large_buttons}>{cancelButton}</Stack.Item>
      {!large_buttons && message && (
        <Stack.Item>
          <Box color="label" textAlign="center">
            {message}
          </Box>
        </Stack.Item>
      )}
      <Stack.Item grow={large_buttons}>{submitButton}</Stack.Item>
    </Stack>
  );
};
