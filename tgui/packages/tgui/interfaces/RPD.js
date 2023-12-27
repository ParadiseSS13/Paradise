import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Tabs, Button, Box, Section, Grid } from '../components';
import { Window } from '../layouts';
import { classes } from 'common/react';

export const RPD = (props, context) => {
  const { act, data } = useBackend(context);
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
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={450} height={415}>
      <Window.Content>
        <Tabs fluid>
          {mainmenu.map((m) => (
            <Tabs.Tab
              key={m.category}
              icon={m.icon}
              selected={m.mode === mode}
              onClick={() => act('mode', { mode: m.mode })}>
              {m.category}
            </Tabs.Tab>
          ))}
        </Tabs>
        {decideTab(mode)}
      </Window.Content>
    </Window>
  );
};

const AtmosPipeContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { pipemenu, pipe_category, pipelist, whatpipe, iconrotation } = data;

  return (
    <Box>
      <Tabs fluid>
        {pipemenu.map((p) => (
          <Tabs.Tab
            key={p.category}
            textAlign="center"
            selected={p.pipemode === pipe_category}
            onClick={() => act('pipe_category', { pipe_category: p.pipemode })}>
            {p.category}
          </Tabs.Tab>  
        ))}
      </Tabs>
      <Section>
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
                    style={{'margin-bottom': '2px'}}
                  />
                </Box>
              ))}
          </Grid.Column>
          <Grid.Column>
            {pipelist
              .filter(
                (p) =>
                  p.pipe_type === 1 &&
                  p.pipe_id === whatpipe &&
                  p.orientations !== 1
              )
              .map((p) => (
                <Box key={p.pipe_id}>
                  <Box>
                    <Button
                      fluid
                      textAlign="center"
                      content="Orient automatically"
                      selected={iconrotation === 0}
                      onClick={() => act('iconrotation', { iconrotation: 0 })}
                    />
                  </Box>
                  {p.bendy ? (
                    <Fragment>
                      <Grid>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            color="transparent"
                            selected={iconrotation === 4}
                            content={
                              <Box
                                className={classes([
                                  'rpd32x32',
                                  `southeast-${p.pipe_icon}`,
                                ])}
                              />
                            }
                            onClick={() =>
                              act('iconrotation', { iconrotation: 4 })
                            }
                          />
                        </Grid.Column>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            color="transparent"
                            selected={iconrotation === 2}
                            content={
                              <Box
                                className={classes([
                                  'rpd32x32',
                                  `southwest-${p.pipe_icon}`,
                                ])}
                              />
                            }
                            onClick={() =>
                              act('iconrotation', { iconrotation: 2 })
                            }
                          />
                        </Grid.Column>
                      </Grid>
                      <Grid>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            color="transparent"
                            selected={iconrotation === 1}
                            content={
                              <Box
                                className={classes([
                                  'rpd32x32',
                                  `northeast-${p.pipe_icon}`,
                                ])}
                              />
                            }
                            onClick={() =>
                              act('iconrotation', { iconrotation: 1 })
                            }
                          />
                        </Grid.Column>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            color="transparent"
                            selected={iconrotation === 8}
                            content={
                              <Box
                                className={classes([
                                  'rpd32x32',
                                  `northwest-${p.pipe_icon}`,
                                ])}
                              />
                            }
                            onClick={() =>
                              act('iconrotation', { iconrotation: 8 })
                            }
                          />
                        </Grid.Column>
                      </Grid>
                    </Fragment>
                  ) : (
                    <Fragment>
                      <Grid>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            color="transparent"
                            selected={iconrotation === 1}
                            content={
                              <Box
                                className={classes([
                                  'rpd32x32',
                                  `north-${p.pipe_icon}`,
                                ])}
                              />
                            }
                            onClick={() =>
                              act('iconrotation', { iconrotation: 1 })
                            }
                          />
                        </Grid.Column>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            color="transparent"
                            selected={iconrotation === 4}
                            content={
                              <Box
                                className={classes([
                                  'rpd32x32',
                                  `east-${p.pipe_icon}`,
                                ])}
                              />
                            }
                            onClick={() =>
                              act('iconrotation', { iconrotation: 4 })
                            }
                          />
                        </Grid.Column>
                      </Grid>
                      {p.orientations === 4 && (
                        <Grid>
                          <Grid.Column>
                            <Button
                              fluid
                              textAlign="center"
                              color="transparent"
                              selected={iconrotation === 2}
                              content={
                                <Box
                                  className={classes([
                                    'rpd32x32',
                                    `south-${p.pipe_icon}`,
                                  ])}
                                />
                              }
                              onClick={() =>
                                act('iconrotation', { iconrotation: 2 })
                              }
                            />
                          </Grid.Column>
                          <Grid.Column>
                            <Button
                              fluid
                              textAlign="center"
                              color="transparent"
                              selected={iconrotation === 8}
                              content={
                                <Box
                                  className={classes([
                                    'rpd32x32',
                                    `west-${p.pipe_icon}`,
                                  ])}
                                />
                              }
                              onClick={() =>
                                act('iconrotation', { iconrotation: 8 })
                              }
                            />
                          </Grid.Column>
                        </Grid>
                      )}
                    </Fragment>
                  )}
                </Box>
              ))}
          </Grid.Column>
        </Grid>
      </Section>
    </Box>
  );
};

const DisposalPipeContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { pipe_category, pipelist, whatdpipe, iconrotation } = data;

  return (
    <Section>
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
                />
              </Box>
            ))}
        </Grid.Column>
        <Grid.Column>
          {pipelist
            .filter(
              (p) =>
                p.pipe_type === 2 &&
                p.pipe_id === whatdpipe &&
                p.orientations !== 1
            )
            .map((p) => (
              <Fragment key={p.pipe_id}>
                <Box>
                  <Button
                    fluid
                    textAlign="center"
                    content="Orient automatically"
                    selected={iconrotation === 0}
                    onClick={() => act('iconrotation', { iconrotation: 0 })}
                  />
                </Box>
                <Grid>
                  <Grid.Column>
                    <Button
                      fluid
                      color="transparent"
                      textAlign="center"
                      selected={iconrotation === 1}
                      content={
                        <Box
                          className={classes([
                            'rpd32x32',
                            `north-${p.pipe_icon}`,
                          ])}
                        />
                      }
                      onClick={() => act('iconrotation', { iconrotation: 1 })}
                    />
                  </Grid.Column>
                  <Grid.Column>
                    <Button
                      fluid
                      color="transparent"
                      textAlign="center"
                      selected={iconrotation === 4}
                      content={
                        <Box
                          className={classes([
                            'rpd32x32',
                            `east-${p.pipe_icon}`,
                          ])}
                        />
                      }
                      onClick={() => act('iconrotation', { iconrotation: 4 })}
                    />
                  </Grid.Column>
                </Grid>
                {p.orientations === 4 && (
                  <Grid>
                    <Grid.Column>
                      <Button
                        fluid
                        color="transparent"
                        textAlign="center"
                        selected={iconrotation === 2}
                        content={
                          <Box
                            className={classes([
                              'rpd32x32',
                              `south-${p.pipe_icon}`,
                            ])}
                          />
                        }
                        onClick={() => act('iconrotation', { iconrotation: 2 })}
                      />
                    </Grid.Column>
                    <Grid.Column>
                      <Button
                        fluid
                        color="transparent"
                        textAlign="center"
                        selected={iconrotation === 8}
                        content={
                          <Box
                            className={classes([
                              'rpd32x32',
                              `west-${p.pipe_icon}`,
                            ])}
                          />
                        }
                        onClick={() => act('iconrotation', { iconrotation: 8 })}
                      />
                    </Grid.Column>
                  </Grid>
                )}
              </Fragment>
            ))}
        </Grid.Column>
      </Grid>
    </Section>
  );
};

// These ones are simple, but are like this incase the RPD gets future refactors
const RotatePipeContent = (props, context) => {
  return <Box bold>Device ready to rotate loose pipes...</Box>;
};

const FlipPipeContent = (props, context) => {
  return <Box bold>Device ready to flip loose pipes...</Box>;
};

const BinPipeContent = (props, context) => {
  return <Box bold>Device ready to eat loose pipes...</Box>;
};
