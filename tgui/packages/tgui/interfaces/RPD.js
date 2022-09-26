import { Fragment } from "inferno";
import { useBackend } from "../backend";
import { Tabs, Button, LabeledList, Box, AnimatedNumber, Section, Grid } from "../components";
import { Window } from "../layouts";

export const RPD = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mainmenu,
    mode,
    auto_wrench,
  } = data;

  const decideTab = index => {
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
    <Window>
      <Window.Content>
        <Tabs>
          {mainmenu.map(m => (
            <Tabs.Tab
              key={m.category}
              content={m.category}
              icon={m.icon}
              selected={m.mode === mode}
              onClick={
                () => act('mode', { mode: m.mode })
              } />
          ))}
          <Button
            fluid
            textAlign="center"
            content="Auto-wrench"
            selected={auto_wrench === 1}
            onClick={
              () => act('auto_wrench', { auto_wrench: !auto_wrench })
            } />
        </Tabs>
        {decideTab(mode)}
      </Window.Content>
    </Window>
  );
};

const AtmosPipeContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    pipemenu,
    pipe_category,
    pipelist,
    whatpipe,
    iconrotation,
  } = data;

  return (
    <Box>
      <Tabs>
        {pipemenu.map(p => (
          <Tabs.Tab
            key={p.category}
            content={p.category}
            selected={p.pipemode === pipe_category}
            onClick={
              () => act('pipe_category', { pipe_category: p.pipemode })
            } />
        ))}
      </Tabs>
      <Section>
        <Grid>
          <Grid.Column>
            {pipelist.filter(p => (p.pipe_type === 1)).filter(p => (p.pipe_category === pipe_category)).map(p => (
              <Box key={p.pipe_name}>
                <Button
                  fluid
                  content={p.pipe_name}
                  icon="cog"
                  selected={p.pipe_id === whatpipe}
                  onClick={
                    () => act('whatpipe', { whatpipe: p.pipe_id })
                  } />
              </Box>
            ))}
          </Grid.Column>
          <Grid.Column>
            {pipelist.filter(p => (p.pipe_type === 1 && p.pipe_id === whatpipe && p.orientations !== 1)).map(p => (
              <Box key={p.pipe_id}>
                <Box>
                  <Button
                    fluid
                    textAlign="center"
                    content="Orient automatically"
                    selected={iconrotation === 0}
                    onClick={
                      () => act('iconrotation', { iconrotation: 0 })
                    } />
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
                            <img src={p.pipe_icon + "-southeast.png"} />
                          }
                          onClick={
                            () => act('iconrotation', { iconrotation: 4 })
                          } />
                      </Grid.Column>
                      <Grid.Column>
                        <Button
                          fluid
                          textAlign="center"
                          color="transparent"
                          selected={iconrotation === 2}
                          content={
                            <img src={p.pipe_icon + "-southwest.png"} />
                          }
                          onClick={
                            () => act('iconrotation', { iconrotation: 2 })
                          } />
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
                            <img src={p.pipe_icon + "-northeast.png"} />
                          }
                          onClick={
                            () => act('iconrotation', { iconrotation: 1 })
                          } />
                      </Grid.Column>
                      <Grid.Column>
                        <Button
                          fluid
                          textAlign="center"
                          color="transparent"
                          selected={iconrotation === 8}
                          content={
                            <img src={p.pipe_icon + "-northwest.png"} />
                          }
                          onClick={
                            () => act('iconrotation', { iconrotation: 8 })
                          } />
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
                            <img src={p.pipe_icon + "-north.png"} />
                          }
                          onClick={
                            () => act('iconrotation', { iconrotation: 1 })
                          } />
                      </Grid.Column>
                      <Grid.Column>
                        <Button
                          fluid
                          textAlign="center"
                          color="transparent"
                          selected={iconrotation === 4}
                          content={
                            <img src={p.pipe_icon + "-east.png"} />
                          }
                          onClick={
                            () => act('iconrotation', { iconrotation: 4 })
                          } />
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
                              <img src={p.pipe_icon + "-south.png"} />
                            }
                            onClick={
                              () => act('iconrotation', { iconrotation: 2 })
                            } />
                        </Grid.Column>
                        <Grid.Column>
                          <Button
                            fluid
                            textAlign="center"
                            color="transparent"
                            selected={iconrotation === 8}
                            content={
                              <img src={p.pipe_icon + "-west.png"} />
                            }
                            onClick={
                              () => act('iconrotation', { iconrotation: 8 })
                            } />
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
  const {
    pipe_category,
    pipelist,
    whatdpipe,
    iconrotation,
  } = data;

  return (
    <Section>
      <Grid>
        <Grid.Column>
          {pipelist.filter(p => (p.pipe_type === 2)).map(p => (
            <Box key={p.pipe_name}>
              <Button
                fluid
                content={p.pipe_name}
                icon="cog"
                selected={p.pipe_id === whatdpipe}
                onClick={
                  () => act('whatdpipe', { whatdpipe: p.pipe_id })
                } />
            </Box>
          ))}
        </Grid.Column>
        <Grid.Column>
          {pipelist.filter(p => (p.pipe_type === 2 && p.pipe_id === whatdpipe && p.orientations !== 1)).map(p => (
            <Fragment key={p.pipe_id}>
              <Box>
                <Button
                  fluid
                  textAlign="center"
                  content="Orient automatically"
                  selected={iconrotation === 0}
                  onClick={
                    () => act('iconrotation', { iconrotation: 0 })
                  } />
              </Box>
              <Grid>
                <Grid.Column>
                  <Button
                    fluid
                    color="transparent"
                    textAlign="center"
                    selected={iconrotation === 1}
                    content={
                      <img src={p.pipe_icon + "-north.png"} />
                    }
                    onClick={
                      () => act('iconrotation', { iconrotation: 1 })
                    } />
                </Grid.Column>
                <Grid.Column>
                  <Button
                    fluid
                    color="transparent"
                    textAlign="center"
                    selected={iconrotation === 4}
                    content={
                      <img src={p.pipe_icon + "-east.png"} />
                    }
                    onClick={
                      () => act('iconrotation', { iconrotation: 4 })
                    } />
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
                        <img src={p.pipe_icon + "-south.png"} />
                      }
                      onClick={
                        () => act('iconrotation', { iconrotation: 2 })
                      } />
                  </Grid.Column>
                  <Grid.Column>
                    <Button
                      fluid
                      color="transparent"
                      textAlign="center"
                      selected={iconrotation === 8}
                      content={
                        <img src={p.pipe_icon + "-west.png"} />
                      }
                      onClick={
                        () => act('iconrotation', { iconrotation: 8 })
                      } />
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
  return (
    <Box bold>
      Device ready to rotate loose pipes...
    </Box>
  );
};

const FlipPipeContent = (props, context) => {
  return (
    <Box bold>
      Device ready to flip loose pipes...
    </Box>
  );
};

const BinPipeContent = (props, context) => {
  return (
    <Box bold>
      Device ready to eat loose pipes...
    </Box>
  );
};
