import { useBackend } from "../../backend";
import { Box, Button, Dropdown, Input, Modal } from '../../components';

export const QuestionModal = (props, context) => {
  const { act } = useBackend(context);
  const { id, question, choices, value } = props;
  return (
    <Modal maxWidth="100%">
      <Box>
        {question}
      </Box>
      {choices ? (
        <Dropdown
          options={choices.split(',')}
          selected={value}
          width="100%"
          my="0.5rem"
          onSelected={val => act('questionmodal_answer', { answer: val })}
        />
      ) : (
        <Input
          value={value}
          placeholder="ENTER to submit"
          width="100%"
          my="0.5rem"
          onEnter={(e, val) => act('questionmodal_answer', { answer: val })}
        />
      )}
      <Button
        icon="arrow-left"
        content="Cancel"
        color="grey"
        onClick={() => act('questionmodal_close')}
      />
    </Modal>
  );
};
