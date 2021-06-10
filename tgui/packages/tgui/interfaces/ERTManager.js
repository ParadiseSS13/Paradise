import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section } from '../components';
import { Window } from '../layouts';

export const ERTManager = (props, context) => {
  const { act, data } = useBackend(context);
  let slotOptions = [0, 1, 2, 3, 4, 5];
  return (
    <Window>
      <Window.Content>
        <Section title="Overview">
          <LabeledList>
            <LabeledList.Item label="Current Alert"
              color={data.security_level_color}>
              {data.str_security_level}
            </LabeledList.Item>
            <LabeledList.Item label="ERT Type">
              <Button
                content="Amber"
                color={data.ert_type === "Amber"
                  ? "orange"
                  : ""}
                onClick={() => act('ert_type', { ert_type: "Amber" })} />
              <Button
                content="Red"
                color={data.ert_type === "Red"
                  ? "red"
                  : ""}
                onClick={() => act('ert_type', { ert_type: "Red" })} />
              <Button
                content="Gamma"
                color={data.ert_type === "Gamma"
                  ? "purple"
                  : ""}
                onClick={() => act('ert_type', { ert_type: "Gamma" })} />
              <br />
              <Button
                content="SolGov"
                color={data.ert_type === "SolGov"
                  ? "red"
                  : ""}
                onClick={() => { act('ert_type', { ert_type: "SolGov" });
                  act('set_med', { set_med: "0" });
                  act('set_eng', { set_eng: "0" });
                  act('set_par', { set_par: "0" });
                  act('set_jan', { set_jan: "0" });
                }} />
              <Button
                content="SolGov Specops"
                color={data.ert_type === "SolGov Specops"
                  ? "purple"
                  : ""}
                onClick={() => { act('ert_type', { ert_type: "SolGov Specops" });
                  act('set_med', { set_med: "0" });
                  act('set_eng', { set_eng: "0" });
                  act('set_par', { set_par: "0" });
                  act('set_jan', { set_jan: "0" });
                }} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Slots">
          <LabeledList>
            <LabeledList.Item label="Commander">
              <Button
                content={data.com > 0 ? "Yes" : "No"}
                selected={data.com > 0}
                onClick={() => act('toggle_com')} />
            </LabeledList.Item>
            <LabeledList.Item label="Security">
              {slotOptions.map((a, i) => (
                <Button
                  key={"sec" + a}
                  selected={data.sec === a}
                  content={a}
                  onClick={() => act('set_sec', {
                    set_sec: a,
                  })}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Medical">
              {slotOptions.map((a, i) => (
                <Button
                  disabled={data.ert_type === "SolGov" || data.ert_type === "SolGov Specops"}
                  key={"med" + a}
                  selected={data.med === a}
                  content={a}
                  onClick={() => act('set_med', {
                    set_med: a,
                  })}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Engineering">
              {slotOptions.map((a, i) => (
                <Button
                  disabled={data.ert_type === "SolGov" || data.ert_type === "SolGov Specops"}
                  key={"eng" + a}
                  selected={data.eng === a}
                  content={a}
                  onClick={() => act('set_eng', {
                    set_eng: a,
                  })}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Paranormal">
              {slotOptions.map((a, i) => (
                <Button
                  disabled={data.ert_type === "SolGov" || data.ert_type === "SolGov Specops"}
                  key={"par" + a}
                  selected={data.par === a}
                  content={a}
                  onClick={() => act('set_par', {
                    set_par: a,
                  })}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Janitor">
              {slotOptions.map((a, i) => (
                <Button
                  disabled={data.ert_type === "SolGov" || data.ert_type === "SolGov Specops"}
                  key={"jan" + a}
                  selected={data.jan === a}
                  content={a}
                  onClick={() => act('set_jan', {
                    set_jan: a,
                  })}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Cyborg">
              {slotOptions.map((a, i) => (
                <Button
                  key={"cyb" + a}
                  selected={data.cyb === a}
                  content={a}
                  onClick={() => act('set_cyb', {
                    set_cyb: a,
                  })}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Total Slots">
              <Box color={data.total > data.spawnpoints
                ? "red"
                : "green"}>
                {data.total} total, versus {data.spawnpoints} spawnpoints
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Dispatch">
              <Button
                icon="ambulance"
                content="Send ERT"
                onClick={() => act('dispatch_ert')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
