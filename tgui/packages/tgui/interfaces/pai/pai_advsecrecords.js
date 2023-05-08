import { useBackend } from "../../backend";
import { LabeledList, Button } from "../../components";

export const pai_advsecrecords = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <LabeledList>
      <LabeledList.Item label="Special Syndicate options:">
        <Button
          content="Select Records"
          onClick={() => act('ui_interact')} />
      </LabeledList.Item>
    </LabeledList>
  );

};
