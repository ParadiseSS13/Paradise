import { useBackend } from "../../backend";
import { LabeledList, Button } from "../../components";

export const pai_camera_bug = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <LabeledList>
      <LabeledList.Item label="Special Syndicate options:">
        <Button
          content="Select Monitor"
          onClick={() => act('ui_interact')} />
      </LabeledList.Item>
    </LabeledList>
  );

};
