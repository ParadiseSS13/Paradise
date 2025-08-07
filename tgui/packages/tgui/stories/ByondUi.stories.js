/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useState } from 'react';
import { Box, Button, ByondUi, Section } from 'tgui-core/components';

import { logger } from '../logging';

export const meta = {
  title: 'ByondUi',
  render: () => <Story />,
};

const Story = (props) => {
  const [code, setCode] = useState(`Byond.winset('${Byond.windowId}', {\n 'is-visible': true,\n})`);
  return (
    <>
      <Section title="Button">
        <ByondUi
          params={{
            type: 'button',
            text: 'Button',
          }}
        />
      </Section>
      <Section
        title="Make BYOND calls"
        buttons={
          <Button
            icon="chevron-right"
            onClick={() =>
              setTimeout(() => {
                try {
                  const result = new Function('return (' + code + ')')();
                  if (result && result.then) {
                    logger.log('Promise');
                    result.then(logger.log);
                  } else {
                    logger.log(result);
                  }
                } catch (err) {
                  logger.log(err);
                }
              })
            }
          >
            Evaluate
          </Button>
        }
      >
        <Box as="textarea" width="100%" height="10em" onChange={(e) => setCode(e.target.value)}>
          {code}
        </Box>
      </Section>
    </>
  );
};
