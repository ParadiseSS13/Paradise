import { useBackend } from "../../backend";
import { Button, Divider, Flex, Section } from "../../components";
import { LatheMaterials, LatheSearch } from "./index";

export const LatheMainMenu = (properties, context) => {
  const { data, act } = useBackend(context);

  const {
    menu,
    categories,
  } = data;

  const label = menu === 4 ? 'Protolathe' : 'Circuit Imprinter';

  return (
    <Section title={label + " Menu"}>
      <LatheMaterials />
      <LatheSearch />

      <Divider />

      <Flex wrap="wrap">
        {categories.map(cat => (
          <Flex key={cat} style={{
            'flex-basis': '50%',
            'margin-bottom': '6px',
          }}>
            <Button
              icon="arrow-right"
              content={cat}
              onClick={() => {
                act('setCategory', { category: cat });
              }} />
          </Flex>
        ))}
      </Flex>

    </Section>
  );
};
