import { Box, Button, Icon, Input, Section, Stack, Tabs } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Grid } from '../components';
import { Window } from '../layouts';

export const RPD = (props) => {
  const { act, data } = useBackend();
  const { mainmenu, mode } = data;

  const decideTab = (index) => {
    switch (index) {
      case 1:
        return <AtmosPipeContent />;
      case 2:
        return <DisposalPipeContent />;
      case 3:
        return <RotatePipeContent />;
      case 4:
        return <FlipPipeContent />;
      case 5:
        return <BinPipeContent />;
      case 6:
        return <TransitTubeContent />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={550} height={440}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid>
              {mainmenu.map((m) => (
                <Tabs.Tab
                  key={m.category}
                  icon={m.icon}
                  selected={m.mode === mode}
                  onClick={() => act('mode', { mode: m.mode })}
                >
                  {m.category}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          {decideTab(mode)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AtmosPipeContent = (props) => {
  const { act, data } = useBackend();
  const { pipemenu, pipe_category, pipelist, whatpipe, iconrotation } = data;

  return (
    <>
      <Stack.Item>
        <Tabs fluid>
          {pipemenu.map((p) => (
            <Tabs.Tab
              key={p.category}
              textAlign="center"
              selected={p.pipemode === pipe_category}
              onClick={() => act('pipe_category', { pipe_category: p.pipemode })}
            >
              {p.category}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item>
        <Input fluid placeholder="Enter pipe label" onChange={(value) => act('set_label', { set_label: value })} />
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow basis="50%">
            <Section fill scrollable>
              <Grid>
                <Grid.Column>
                  {pipelist
                    .filter((p) => p.pipe_type === 1)
                    .filter((p) => p.pipe_category === pipe_category)
                    .map((p) => (
                      <Box key={p.pipe_name}>
                        <Button
                          fluid
                          content={p.pipe_name}
                          icon="cog"
                          selected={p.pipe_id === whatpipe}
                          onClick={() => act('whatpipe', { whatpipe: p.pipe_id })}
                          style={{ marginBottom: '2px' }}
                        />
                      </Box>
                    ))}
                </Grid.Column>
              </Grid>
            </Section>
          </Stack.Item>
          <Stack.Item grow basis="50%">
            <Section fill>
              <Grid>
                <Grid.Column>
                  <ActionButtons />
                  {pipelist
                    .filter((p) => p.pipe_type === 1 && p.pipe_id === whatpipe && p.orientations !== 1)
                    .map((p) => (
                      <Box key={p.pipe_id}>
                        {p.bendy ? (
                          <>
                            <Grid>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  selected={iconrotation === 4}
                                  content={<Box className={classes(['rpd32x32', `southeast-${p.pipe_icon}`])} />}
                                  onClick={() => act('iconrotation', { iconrotation: 4 })}
                                  style={{ marginBottom: '5px' }}
                                />
                              </Grid.Column>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  selected={iconrotation === 2}
                                  content={<Box className={classes(['rpd32x32', `southwest-${p.pipe_icon}`])} />}
                                  onClick={() => act('iconrotation', { iconrotation: 2 })}
                                  style={{ marginBottom: '5px' }}
                                />
                              </Grid.Column>
                            </Grid>
                            <Grid>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  selected={iconrotation === 1}
                                  content={<Box className={classes(['rpd32x32', `northeast-${p.pipe_icon}`])} />}
                                  onClick={() => act('iconrotation', { iconrotation: 1 })}
                                  style={{ marginBottom: '5px' }}
                                />
                              </Grid.Column>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  selected={iconrotation === 8}
                                  content={<Box className={classes(['rpd32x32', `northwest-${p.pipe_icon}`])} />}
                                  onClick={() => act('iconrotation', { iconrotation: 8 })}
                                  style={{ marginBottom: '5px' }}
                                />
                              </Grid.Column>
                            </Grid>
                          </>
                        ) : (
                          <>
                            <Grid>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  selected={iconrotation === 1}
                                  content={<Box className={classes(['rpd32x32', `north-${p.pipe_icon}`])} />}
                                  onClick={() => act('iconrotation', { iconrotation: 1 })}
                                  style={{ marginBottom: '5px' }}
                                />
                              </Grid.Column>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  selected={iconrotation === 4}
                                  content={<Box className={classes(['rpd32x32', `east-${p.pipe_icon}`])} />}
                                  onClick={() => act('iconrotation', { iconrotation: 4 })}
                                  style={{ marginBottom: '5px' }}
                                />
                              </Grid.Column>
                            </Grid>
                            {p.orientations === 4 && (
                              <Grid>
                                <Grid.Column>
                                  <Button
                                    fluid
                                    textAlign="center"
                                    selected={iconrotation === 2}
                                    content={<Box className={classes(['rpd32x32', `south-${p.pipe_icon}`])} />}
                                    onClick={() => act('iconrotation', { iconrotation: 2 })}
                                    style={{ marginBottom: '5px' }}
                                  />
                                </Grid.Column>
                                <Grid.Column>
                                  <Button
                                    fluid
                                    textAlign="center"
                                    selected={iconrotation === 8}
                                    content={<Box className={classes(['rpd32x32', `west-${p.pipe_icon}`])} />}
                                    onClick={() => act('iconrotation', { iconrotation: 8 })}
                                    style={{ marginBottom: '5px' }}
                                  />
                                </Grid.Column>
                              </Grid>
                            )}
                          </>
                        )}
                      </Box>
                    ))}
                </Grid.Column>
              </Grid>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </>
  );
};

const DisposalPipeContent = (props) => {
  const { act, data } = useBackend();
  const { pipe_category, pipelist, whatdpipe, iconrotation, auto_wrench_toggle } = data;

  return (
    <Stack.Item grow>
      <Stack fill>
        <Stack.Item grow basis="50%">
          <Section fill>
            <Grid>
              <Grid.Column>
                {pipelist
                  .filter((p) => p.pipe_type === 2)
                  .map((p) => (
                    <Box key={p.pipe_name}>
                      <Button
                        fluid
                        content={p.pipe_name}
                        icon="cog"
                        selected={p.pipe_id === whatdpipe}
                        onClick={() => act('whatdpipe', { whatdpipe: p.pipe_id })}
                        style={{ marginBottom: '2px' }}
                      />
                    </Box>
                  ))}
              </Grid.Column>
            </Grid>
          </Section>
        </Stack.Item>
        <Stack.Item grow basis="50%">
          <Section fill>
            <Grid>
              <Grid.Column>
                <ActionButtons />
                {pipelist
                  .filter((p) => p.pipe_type === 2 && p.pipe_id === whatdpipe && p.orientations !== 1)
                  .map((p) => (
                    <Stack.Item key={p.pipe_id}>
                      <Grid>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            selected={iconrotation === 1}
                            content={<Box className={classes(['rpd32x32', `north-${p.pipe_icon}`])} />}
                            onClick={() => act('iconrotation', { iconrotation: 1 })}
                            style={{ marginBottom: '5px' }}
                          />
                        </Grid.Column>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            selected={iconrotation === 4}
                            content={<Box className={classes(['rpd32x32', `east-${p.pipe_icon}`])} />}
                            onClick={() => act('iconrotation', { iconrotation: 4 })}
                            style={{ marginBottom: '5px' }}
                          />
                        </Grid.Column>
                      </Grid>
                      {p.orientations === 4 && (
                        <Grid>
                          <Grid.Column>
                            <Button
                              fluid
                              textAlign="center"
                              selected={iconrotation === 2}
                              content={<Box className={classes(['rpd32x32', `south-${p.pipe_icon}`])} />}
                              onClick={() => act('iconrotation', { iconrotation: 2 })}
                              style={{ marginBottom: '5px' }}
                            />
                          </Grid.Column>
                          <Grid.Column>
                            <Button
                              fluid
                              textAlign="center"
                              selected={iconrotation === 8}
                              content={<Box className={classes(['rpd32x32', `west-${p.pipe_icon}`])} />}
                              onClick={() => act('iconrotation', { iconrotation: 8 })}
                              style={{ marginBottom: '5px' }}
                            />
                          </Grid.Column>
                        </Grid>
                      )}
                    </Stack.Item>
                  ))}
              </Grid.Column>
            </Grid>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const ActionButtons = (props) => {
  const { act, data } = useBackend();
  const { iconrotation, auto_wrench_toggle } = data;

  return (
    <Stack mb={1} textAlign="center">
      <Stack.Item basis="50%">
        <Button
          fluid
          content="Auto-orientation"
          selected={iconrotation === 0}
          onClick={() => act('iconrotation', { iconrotation: 0 })}
        />
      </Stack.Item>
      <Stack.Item basis="50%">
        <Button.Checkbox
          fluid
          checked={auto_wrench_toggle}
          content="Auto-anchor"
          onClick={() => act('auto_wrench_toggle')}
        />
      </Stack.Item>
    </Stack>
  );
};

const RotatePipeContent = (props) => {
  return (
    <Stack.Item grow>
      <Section fill>
        <Stack fill>
          <Stack.Item bold grow textAlign="center" align="center">
            <Icon name="sync-alt" size={5} color="gray" mb={5} />
            <br />
            Device ready to rotate loose pipes...
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const FlipPipeContent = (props) => {
  return (
    <Stack.Item grow>
      <Section fill>
        <Stack fill>
          <Stack.Item bold grow textAlign="center" align="center">
            <Icon name="arrows-alt-h" size={5} color="gray" mb={5} />
            <br />
            Device ready to flip loose pipes...
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const BinPipeContent = (props) => {
  return (
    <Stack.Item grow>
      <Section fill>
        <Stack fill>
          <Stack.Item bold grow textAlign="center" align="center">
            <Icon name="recycle" size={5} color="gray" mb={5} />
            <br />
            Device ready to eat loose pipes...
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const TransitTubeContent = (props) => {
  const { act, data } = useBackend();
  const { pipe_category, pipelist, whatttube, iconrotation } = data;
  let transit_pipe_type = 3;

  return (
    <Stack.Item grow>
      <Stack fill>
        <Stack.Item grow basis="50%">
          <Section fill>
            <Grid>
              <Grid.Column>
                {pipelist
                  .filter((p) => p.pipe_type === transit_pipe_type)
                  .map((p) => (
                    <Box key={p.pipe_name}>
                      <Button
                        fluid
                        content={p.pipe_name}
                        icon="cog"
                        selected={p.pipe_id === whatttube}
                        onClick={() => act('whatttube', { whatttube: p.pipe_id })}
                        style={{ marginBottom: '2px' }}
                      />
                    </Box>
                  ))}
              </Grid.Column>
            </Grid>
          </Section>
        </Stack.Item>
        <Stack.Item grow basis="50%">
          <Section fill>
            <Grid>
              <Grid.Column>
                <ActionButtons />
                {pipelist
                  .filter((p) => p.pipe_type === transit_pipe_type && p.pipe_id === whatttube && p.orientations !== 1)
                  .map((p) => (
                    <Stack.Item key={p.pipe_id}>
                      <Grid>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            selected={iconrotation === 1}
                            content={<Box className={classes(['rpd32x32', `north-${p.pipe_icon}`])} />}
                            onClick={() => act('iconrotation', { iconrotation: 1 })}
                            style={{ marginBottom: '5px' }}
                          />
                        </Grid.Column>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            selected={iconrotation === 4}
                            content={<Box className={classes(['rpd32x32', `east-${p.pipe_icon}`])} />}
                            onClick={() => act('iconrotation', { iconrotation: 4 })}
                            style={{ marginBottom: '5px' }}
                          />
                        </Grid.Column>
                      </Grid>
                      {p.orientations === 4 && (
                        <Grid>
                          <Grid.Column>
                            <Button
                              fluid
                              textAlign="center"
                              selected={iconrotation === 2}
                              content={<Box className={classes(['rpd32x32', `south-${p.pipe_icon}`])} />}
                              onClick={() => act('iconrotation', { iconrotation: 2 })}
                              style={{ marginBottom: '5px' }}
                            />
                          </Grid.Column>
                          <Grid.Column>
                            <Button
                              fluid
                              textAlign="center"
                              selected={iconrotation === 8}
                              content={<Box className={classes(['rpd32x32', `west-${p.pipe_icon}`])} />}
                              onClick={() => act('iconrotation', { iconrotation: 8 })}
                              style={{ marginBottom: '5px' }}
                            />
                          </Grid.Column>
                        </Grid>
                      )}
                    </Stack.Item>
                  ))}
              </Grid.Column>
            </Grid>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
