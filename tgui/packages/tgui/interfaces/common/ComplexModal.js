import { useBackend } from "../../backend";
import { Box, Button, Dropdown, Flex, Input, Modal } from '../../components';

let bodyOverrides = {};

export const modalOpen = (context, id, args) => {
  const { act, data } = useBackend(context);
  const newArgs = Object.assign(data.modal ? data.modal.args : {}, args || {});

  act('modal_open', {
    id: id,
    arguments: JSON.stringify(newArgs),
  });
};

export const modalRegisterBodyOverride = (id, bodyOverride) => {
  bodyOverrides[id] = bodyOverride;
};

const modalAnswer = (context, id, answer, args) => {
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

const modalClose = (context, id) => {
  const { act } = useBackend(context);
  act('modal_close', {
    id: id,
  });
};

export const ComplexModal = (props, context) => {
  const { act, data } = useBackend(context);
  if (!data.modal) {
    return;
  }

  const {
    id,
    text,
    args,
    type,
  } = data.modal;

  let modalBody;
  let modalFooter = (
    <Button
      icon="arrow-left"
      content="Cancel"
      color="grey"
      onClick={() => modalClose(context)}
    />
  );

  // Different contents depending on the type
  if (bodyOverrides[id]) {
    modalBody = bodyOverrides[id](data.modal, context);
  } else if (type === "input") {
    modalBody = (
      <Input
        value={data.modal.value}
        placeholder="ENTER to submit"
        width="100%"
        my="0.5rem"
        autofocus
        onEnter={(e, val) => modalAnswer(context, id, val)}
      />
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
      mx="auto">
      <Box display="inline">
        {text}
      </Box>
      {modalBody}
      {modalFooter}
    </Modal>
  );
};
