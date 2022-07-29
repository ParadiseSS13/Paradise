import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, Section, Slider } from '../components';
import { Window } from '../layouts';

export const GeneReactorMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { stats } = data;
  return (
    <Window theme="changeling">
      <Window.Content>
        <Section height="100%" overflow="auto">
          {stats.map((stat, key) => (
            <Fragment key={stat.name}>
              <Box fontSize="1.25rem" color="white" mt={key > 0 && '0.5rem'}>
                {stat.name} <Box float="right">{"genetic damage"} : {stat.gene_damage}</Box>
              </Box>
              <Box mt="0.5rem">
                <Flex>
                  <Flex.Item>
                    <Button width="24px" color="purple">
                      <Icon
                        name="fast-backward"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() =>
                          act('stat_change', { stat_key: stat.name, value: -2 + stat.gene_damage})
                        }
                      />
                    </Button>
                  </Flex.Item>
                  <Flex.Item grow="1" mx="1rem">
                    <Slider
                      color="purple"
                      minValue={-2 + stat.gene_damage}
                      maxValue={2 - stat.gene_damage}
                      stepPixelSize={19}
                      step={0.2}
                      value={stat.value}
                      onChange={(e, value) =>
                        act('stat_change', { stat_key: stat.name, value: value })
                      }
                    />
                  </Flex.Item>
                  <Flex.Item>
                    <Button width="24px" color="purple">
                      <Icon
                        name="fast-forward"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() =>
                          act('stat_change', { stat_key: stat.name, value: 2 - stat.gene_damage})
                        }
                      />
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
            </Fragment>
          ))}
          <Flex.Item mt={2} float="right">
            <Button
              width="106px"
              content="RESET VALUES"
              color="purple"
              mt={2}
              onClick={() => act('stat_reset')}
            />
          </Flex.Item>
        </Section>
      </Window.Content>
    </Window>
  );
};
