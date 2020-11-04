import { useBackend } from "../../backend";
import { Box, Button, Dropdown, Flex, Input, Modal } from '../../components';

let bodyOverrides = {};

/**
 * Sends a call to BYOND to open a modal
 * @param {any} context The React context
 * @param {string} id The identifier of the modal
 * @param {object=} args The arguments to pass to the modal
 */
export const modalOpen = (context, id, args) => {
  const { act, data } = useBackend(context);
  const newArgs = Object.assign(data.modal ? data.modal.args : {}, args || {});

  act('modal_open', {
    id: id,
    arguments: JSON.stringify(newArgs),
  });
};

/**
 * Registers an override for any modal with the given id
 * @param {string} id The identifier of the modal
 * @param {function} bodyOverride The override function that returns the
 *    modal contents
 */
export const modalRegisterBodyOverride = (id, bodyOverride) => {
  bodyOverrides[id] = bodyOverride;
};

export const modalAnswer = (context, id, answer, args) => {
  const { act, data } = useBackend(context);
  if (!data.modal) {
    return;
  }

  const newArgs = Object.assign(data.modal.args || {}, args || {});
  act('modal_answer', {
    id: id,
    answer: answer,
    arguments: JSON.stringify(newArgs),
  });
};

export const modalClose = (context, id) => {
  const { act } = useBackend(context);
  act('modal_close', {
    id: id,
  });
};

/**
 * Displays a modal and its actions. Passed data must have a valid modal field
 *
 * **A valid modal field contains:**
 *
 * `id` — The identifier of the modal.
 * Used for server-client communication and overriding
 *
 * `text` — The text of the modal
 *
 * `type` — The type of the modal:
 * `message`, `input`, `choice`, `bento` and `boolean`.
 * Overriden by a body override registered to the identifier if applicable.
 * Defaults to `message` if not found
 * @param {object} props
 * @param {object} context
 */
export const ComplexModal = (props, context) => {
  const { data } = useBackend(context);
  if (!data.modal) {
    return;
  }

  const {
    id,
    text,
    type,
  } = data.modal;

  let modalOnEnter;
  let modalBody;
  let modalFooter = (
    <Button
      icon="arrow-left"
      content="Cancel"
      color="grey"
      onClick={() => modalClose(context)}
    />
  );
  let overflowY = "auto";

  // Different contents depending on the type
  if (bodyOverrides[id]) {
    modalBody = bodyOverrides[id](data.modal, context);
  } else if (type === "input") {
    let curValue = data.modal.value;
    modalOnEnter = e => modalAnswer(context, id, curValue);
    modalBody = (
      <Input
        value={data.modal.value}
        placeholder="ENTER to submit"
        width="100%"
        my="0.5rem"
        autofocus
        onChange={(_e, val) => {
          curValue = val;
        }}
      />
    );
    modalFooter = (
      <Box mt="0.5rem">
        <Button
          icon="arrow-left"
          content="Cancel"
          color="grey"
          onClick={() => modalClose(context)}
        />
        <Button
          icon="check"
          content={"Confirm"}
          color="good"
          float="right"
          m="0"
          onClick={() => modalAnswer(context, id, curValue)}
        />
        <Box clear="both" />
      </Box>
    );
  } else if (type === "choice") {
    const realChoices = (typeof data.modal.choices === "object")
      ? Object.values(data.modal.choices)
      : data.modal.choices;
    modalBody = (
      <Dropdown
        options={realChoices}
        selected={data.modal.value}
        width="100%"
        my="0.5rem"
        onSelected={val => modalAnswer(context, id, val)}
      />
    );
    overflowY = "initial";
  } else if (type === "bento") {
    modalBody = (
      <Flex
        spacingPrecise="1"
        wrap="wrap"
        my="0.5rem"
        maxHeight="1%">
        {data.modal.choices.map((c, i) => (
          <Flex.Item key={i} flex="1 1 auto">
            <Button
              selected={(i + 1) === parseInt(data.modal.value, 10)}
              onClick={() => modalAnswer(context, id, i + 1)}>
              <img src={c} />
            </Button>
          </Flex.Item>
        ))}
      </Flex>
    );
  } else if (type === "boolean") {
    modalFooter = (
      <Box mt="0.5rem">
        <Button
          icon="times"
          content={data.modal.no_text}
          color="bad"
          float="left"
          mb="0"
          onClick={() => modalAnswer(context, id, 0)}
        />
        <Button
          icon="check"
          content={data.modal.yes_text}
          color="good"
          float="right"
          m="0"
          onClick={() => modalAnswer(context, id, 1)}
        />
        <Box clear="both" />
      </Box>
    );
  }

  return (
    <Modal
      maxWidth={props.maxWidth || (window.innerWidth / 2 + "px")}
      maxHeight={props.maxHeight || (window.innerHeight / 2 + "px")}
      onEnter={modalOnEnter}
      mx="auto"
      overflowY={overflowY}>
      <Box display="inline">
        {text}
      </Box>
      {modalBody}
      {modalFooter}
    </Modal>
  );
};
