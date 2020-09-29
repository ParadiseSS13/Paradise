import { useBackend } from "../../backend";
import { Button, LabeledList, Section } from "../../components";

export const DeconstructionMenu = (properties, context) => {
  const { data, act } = useBackend(context);

  const {
    loaded_item,
    linked_destroy,
  } = data;

  if (!linked_destroy) {
    return (
      <div>
        NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE
      </div>
    );
  }

  if (!loaded_item) {
    return (
      <div>
        No item loaded. Standing by...
      </div>
    );
  }

  return (
    <Section noTopPadding>
      <h3>Deconstruction Menu:</h3>
      <div>Name: {loaded_item.name}</div>
      <h3 style={{ 'margin-top': '10px' }}>Origin Tech:</h3>
      <LabeledList>
        {loaded_item.origin_tech.map(item => {
          return (
            <LabeledList.Item labelColor="yellow" color="yellow" label={"* " + item.name} key={item.name}>
              {item.object_level}
              {" "}
              {item.current_level ? (
                <>(Current: {item.current_level})</>
              ) : null}
            </LabeledList.Item>
          );
        })}

      </LabeledList>
      <h3 style={{ 'margin-top': '10px' }}>Options:</h3>
      <Button
        icon="unlink"
        onClick={() => {
          act('deconstruct');
        }}>
        Deconstruct Item
      </Button>
      <Button
        onClick={() => {
          act('eject_item');
        }}>
        <i className="fa fa-eject" />
        Eject Item
      </Button>
    </Section>
  );
};
