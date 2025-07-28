import { Button, Divider, Flex, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { LatheMaterials } from './LatheMaterials';
import { LatheSearch } from './LatheSearch';

export const LatheMainMenu = (properties) => {
  const { data, act } = useBackend();

  const { menu, categories } = data;

  const label = menu === 4 ? 'Protolathe' : 'Circuit Imprinter';

  return (
    <Section title={label + ' Menu'}>
      <LatheMaterials />
      <LatheSearch />

      <Divider />

      <Flex wrap="wrap">
        {categories.map((cat) => (
          <Flex
            key={cat}
            style={{
              flexBasis: '50%',
              marginBottom: '6px',
            }}
          >
            <Button
              icon="arrow-right"
              content={cat}
              onClick={() => {
                act('setCategory', { category: cat });
              }}
            />
          </Flex>
        ))}
      </Flex>
    </Section>
  );
};
