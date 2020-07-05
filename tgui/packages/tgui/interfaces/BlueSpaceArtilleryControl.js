import { useBackend } from "../backend";
import { Button, LabeledList, Section, Box, ProgressBar } from "../components";
import { Window } from "../layouts";

export const BlueSpaceArtilleryControl = (props, context) => {
  const { act, data } = useBackend(context);
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
            <LabeledList.Item label="Target">
              <Button
                icon="crosshairs"
                content={data.target ? data.target : "None"}
                onClick={() => act("recalibrate")} />
            </LabeledList.Item>
            {data.ready === 1 && !!data.target && (
              <LabeledList.Item label="Firing">
                <Button
                  icon="burn"
                  content={"FIRE!"}
                  color={"red"}
                  onClick={() => act("fire")} />
              </LabeledList.Item>
            )}
            {!data.ready && data.reloadtime_text && (
              <LabeledList.Item label="Reloading In">
                {data.reloadtime_text}
              </LabeledList.Item>
            )}
            {!data.ready && !data.reloadtime_text && (
              <LabeledList.Item label="Status" color="red">
                No cannon connected!
              </LabeledList.Item>
            )}
            {!data.connected && (
              <LabeledList.Item label="Status">
                <Button
                  icon="wrench"
                  content={"Complete Deployment"}
                  onClick={() => act("build")} />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};