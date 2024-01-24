import { Loader } from './common/Loader';
import { useBackend, useLocalState } from '../backend';
import {
  KEY_ENTER,
  KEY_ESCAPE,
  KEY_LEFT,
  KEY_RIGHT,
  KEY_SPACE,
  KEY_TAB,
} from '../../common/keycodes';
import { Autofocus, Box, Button, Flex, Section, Stack } from '../components';
import { Window } from '../layouts';

type AlertModalData = {
  autofocus: boolean;
  buttons: string[];
  large_buttons: boolean;
  message: string;
  swapped_buttons: boolean;
  timeout: number;
  title: string;
};

const KEY_DECREMENT = -1;
const KEY_INCREMENT = 1;

export const AlertModal = (props, context) => {
  const { act, data } = useBackend<AlertModalData>(context);
  const {
    autofocus,
    buttons = [],
    large_buttons,
    message = '',
    timeout,
    title,
  } = data;
  const [selected, setSelected] = useLocalState<number>(context, 'selected', 0);
  // Dynamically sets window dimensions
  const windowHeight =
    110 +
    (message.length > 30 ? Math.ceil(message.length / 4) : 0) +
    (message.length && large_buttons ? 5 : 0);
  const windowWidth = 325 + (buttons.length > 2 ? 100 : 0);
  const onKey = (direction: number) => {
    if (selected === 0 && direction === KEY_DECREMENT) {
      setSelected(buttons.length - 1);
    } else if (selected === buttons.length - 1 && direction === KEY_INCREMENT) {
      setSelected(0);
    } else {
      setSelected(selected + direction);
    }
  };

  return (
    <Window title={title} height={windowHeight} width={windowWidth}>
      {!!timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(e) => {
          const keyCode = window.event ? e.which : e.keyCode;
          /**
           * Simulate a click when pressing space or enter,
           * allow keyboard navigation, override tab behavior
           */
          if (keyCode === KEY_SPACE || keyCode === KEY_ENTER) {
            act('choose', { choice: buttons[selected] });
          } else if (keyCode === KEY_ESCAPE) {
            act('cancel');
          } else if (keyCode === KEY_LEFT) {
            e.preventDefault();
            onKey(KEY_DECREMENT);
          } else if (keyCode === KEY_TAB || keyCode === KEY_RIGHT) {
            e.preventDefault();
            onKey(KEY_INCREMENT);
          }
        }}
      >
        <Section fill>
          <Stack fill vertical>
            <Stack.Item grow m={1}>
              <Box color="label" overflow="hidden">
                {message}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {!!autofocus && <Autofocus />}
              <ButtonDisplay selected={selected} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/**
 * Displays a list of buttons ordered by user prefs.
 * Technically this handles more than 2 buttons, but you
 * should just be using a list input in that case.
 */
const ButtonDisplay = (props, context) => {
  const { data } = useBackend<AlertModalData>(context);
  const { buttons = [], large_buttons, swapped_buttons } = data;
  const { selected } = props;

  return (
    <Flex
      fill
      align="center"
      direction={!swapped_buttons ? 'row-reverse' : 'row'}
      justify="space-around"
      wrap
    >
      {buttons?.map((button, index) =>
        !!large_buttons && buttons.length < 3 ? (
          <Flex.Item grow key={index}>
            <AlertButton
              button={button}
              id={index.toString()}
              selected={selected === index}
            />
          </Flex.Item>
        ) : (
          <Flex.Item grow={large_buttons ? 1 : 0} key={index}>
            <AlertButton
              button={button}
              id={index.toString()}
              selected={selected === index}
            />
          </Flex.Item>
        )
      )}
    </Flex>
  );
};

/**
 * Displays a button with variable sizing.
 */
const AlertButton = (props, context) => {
  const { act, data } = useBackend<AlertModalData>(context);
  const { large_buttons } = data;
  const { button, selected } = props;
  const buttonWidth = button.length > 7 ? '100%' : 7;

  return (
    <Button
      mx={large_buttons ? 1 : 0}
      pt={large_buttons ? 0.33 : 0}
      content={button}
      fluid={!!large_buttons}
      onClick={() => act('choose', { choice: button })}
      selected={selected}
      textAlign="center"
      height={!!large_buttons && 2}
      width={!large_buttons && buttonWidth}
    />
  );
};
