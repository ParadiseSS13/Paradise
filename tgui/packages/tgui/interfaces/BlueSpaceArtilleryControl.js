import { useBackend } from "../backend";
import { Button, LabeledList, Section, Box, ProgressBar } from "../components";
import { Window } from "../layouts";

export const BlueSpaceArtilleryControl = (props, context) => {
  const { act, data } = useBackend(context);
  let alertStatus;
  if (data.ready) {
    alertStatus = (
      <LabeledList.Item label="Status" color="green">
        Ready
      </LabeledList.Item>
    );
  } else if (data.reloadtime_text) {
    alertStatus = (
      <LabeledList.Item label="Reloading In" color="red">
        {data.reloadtime_text}
      </LabeledList.Item>
    );
  } else {
    alertStatus = (
      <LabeledList.Item label="Status" color="red">
        No cannon connected!
      </LabeledList.Item>
    );
  }
  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            {data.notice && (
              <LabeledList.Item label="Alert" color="red">
                {data.notice}
              </LabeledList.Item>
            )}
            {alertStatus}
            <LabeledList.Item label="Target">
              <Button
                icon="crosshairs"
                content={data.target ? data.target : "None"}
                onClick={() => act("recalibrate")} />
            </LabeledList.Item>
            {data.ready === 1 && !!data.target && (
              <LabeledList.Item label="Firing">
                <Button
                  icon="skull"
                  content="FIRE!"
                  color="red"
                  onClick={() => act("fire")} />
              </LabeledList.Item>
            )}
            {!data.connected && (
              <LabeledList.Item label="Maintenance">
                <Button
                  icon="wrench"
                  content="Complete Deployment"
                  onClick={() => act("build")} />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
