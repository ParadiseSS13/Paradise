import { useBackend } from "../backend";
import { LabeledList, Section } from "../components";
import { Window } from "../layouts";

export const PodTracking = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    pods,
  } = data;
  return (
    <Window>
      <Window.Content scrollable>
        {pods.map(p => (
          <Section title={p.name} key={p.name}>
            <LabeledList>
              <LabeledList.Item label="Position">
                {p.podx}, {p.pody}, {p.podz}
              </LabeledList.Item>
              <LabeledList.Item label="Pilot">
                {p.pilot}
              </LabeledList.Item>
              <LabeledList.Item label="Passengers">
                {p.passengers}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
