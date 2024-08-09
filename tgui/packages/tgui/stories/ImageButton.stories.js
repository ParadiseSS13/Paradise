/**
 * @file
 * @copyright 2024 Aylong (https://github.com/AyIong)
 * @license MIT
 */

import { useLocalState } from '../backend';
import { Button, LabeledList, ImageButton, Input, Slider, Section, Stack } from '../components';

export const meta = {
  title: 'ImageButton',
  render: () => <Story />,
};

const COLORS_SPECTRUM = [
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
  'gold',
];

const COLORS_STATES = ['good', 'average', 'bad', 'black', 'white'];

const Story = (props, context) => {
  const [disabled, setDisabled] = useLocalState(context, 'disabled', false);
  const [onClick, setOnClick] = useLocalState(context, 'onClick', true);
  const [vertical1, setVertical1] = useLocalState(context, 'vertical1', true);
  const [vertical2, setVertical2] = useLocalState(context, 'vertical2', true);
  const [vertical3, setVertical3] = useLocalState(context, 'vertical3', false);
  const [title, setTitle] = useLocalState(context, 'title', 'Image Button');
  const [content, setContent] = useLocalState(context, 'content', 'Image is a LIE!');
  const [itemContent, setItemContent] = useLocalState(context, 'itemContent', 'Second Button');
  const [itemIcon, setItemIcon] = useLocalState(context, 'itemIcon', 'face-smile');

  const [itemIconPos, setItemIconPos] = useLocalState(context, 'itemIconPos', 'default');

  const [itemIconSize, setItemIconSize] = useLocalState(context, 'itemIconSize', 2);

  const [imageSize, setImageSize] = useLocalState(context, 'imageSize', 64);

  const toggleVertical1 = () => {
    setVertical1(!vertical1);
  };

  const toggleVertical2 = () => {
    setVertical2(!vertical2);
  };

  const toggleVertical3 = () => {
    setVertical3(!vertical3);
  };

  const toggleDisabled = () => {
    setDisabled(!disabled);
  };

  const toggleOnClick = () => {
    setOnClick(!onClick);
  };

  return (
    <>
      <Section>
        <Stack>
          <Stack.Item basis="50%">
            <LabeledList>
              <LabeledList.Item label="Title">
                <Input value={title} onInput={(e, value) => setTitle(value)} />
              </LabeledList.Item>
              <LabeledList.Item label="Content">
                <Input value={content} onInput={(e, value) => setContent(value)} />
              </LabeledList.Item>
              <LabeledList.Item label="Image Size">
                <Slider
                  animated
                  width={10}
                  value={imageSize}
                  minValue={0}
                  maxValue={256}
                  step={1}
                  stepPixelSize={2}
                  onChange={(e, value) => setImageSize(value)}
                />
              </LabeledList.Item>
            </LabeledList>
            <Stack mt={1} mr={2}>
              <Stack.Item grow>
                <Button.Checkbox fluid content="onClick" checked={onClick} onClick={toggleOnClick} />
              </Stack.Item>
              <Stack.Item grow>
                <Button.Checkbox fluid content="Vertical" checked={vertical3} onClick={toggleVertical3} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item basis="50%">
            <LabeledList>
              <LabeledList.Item label="Item Content">
                <Input value={itemContent} onInput={(e, value) => setItemContent(value)} />
              </LabeledList.Item>
              <LabeledList.Item label="Item Icon">
                <Input value={itemIcon} onInput={(e, value) => setItemIcon(value)} />
              </LabeledList.Item>
              <LabeledList.Item label="Item IconPos">
                <Input value={itemIconPos} onInput={(e, value) => setItemIconPos(value)} />
              </LabeledList.Item>
              <LabeledList.Item label="Item IconSize">
                <Slider
                  animated
                  width={10}
                  value={itemIconSize}
                  minValue={0}
                  maxValue={20}
                  step={1}
                  stepPixelSize={10}
                  onChange={(e, value) => setItemIconSize(value)}
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
        <Stack.Item mt={1}>
          <ImageButton
            width={vertical3 && `${imageSize}px`}
            ellipsis={vertical3}
            vertical={vertical3}
            disabled={disabled}
            title={title}
            content={content}
            tooltip={vertical3 ? content : 'Cool and simple buttons with images, FOR ALL!!!'}
            image={
              'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAGo0lEQVRYhe3Xa2xT9xnH8e+5+O4ktuM4cS5OYmhCQ1xcYMCgA9rSbKUqqqpWkzq1mgBtq/piaqna7UXXaTfWddL6opO2dlu1aSBVjJZC19FByyUadKGCJIYQAoHEODi2k/hyTnw/x3uxwZpBtq6qhib1efU/5/9/9Hz0O0c6OsLhw4e5mSXe1On/94BAIFAJBAKV/zkgEAhU7HZ7JRQKCaFQSLDb7Z8Y8l8BPjpYVVXh6n1VVT8xRAbY953HP1bTvn8u/9P56/arHNp1h9Y/9YogX73wBW0fx/CpVXIsA/wjgav1pW//mVdPRYhlp6gxWzAYTCRnM0zPKsRnpjBK4JEqqIUi/fEppKxCRReQLFbEikYmOk5ONNPc0s4v1nXgKChEJmNY7dUs+fwXqPfdSjan8Ktv3XVt5hxAR4OT5zcIjGW6ODGd57IyQ53bhVkSMcsSt1RZiOUKSAIsqjFhl+C5gYvMFnK4JXhLLbDZZaVqzyv8YOsLxFIq0XQRE7Ckw8s3n9nGfVu2zUliDmAs8i7xK6dZ0LGeZmc3JYMXs1im1iTjNErUmwVqChqiCJVKhd6pNCaTBU0QOJHJstZZg3/H9/n9r/cy8C+RHxiJMrj1aXbaq+cHvLb/PQqaCVf4PZa1DbGx+xGGkkYMlSI1okitDEZdp29qlrNJBYOgs8ZRxZkZHbmxhs6+PezfvZch0YTTAK1OG5GCQDpXRNTLxIo5vvf8D3nwi3UoKel6gLdpBeVyCNnmRbI00GwWsdQKfBDXiaST+KwO+pIlehMKwRoDzRYDI6lZbnFUcb+viZNvjnIuBat91XxlkRMLGgNJHVWuYlfoEoWixMXIJFB34wTW3ebj7VNh4mOjpBNh8q6lVBtcvHV+jCqTjM8qUchm6fFWUW8xUdBheYOZdC7PleQM0XQKswxtdol6jxMdI3fWafTFsnR4HJzQRIp6bv5HcKj/Q6TZGOpUkaFLFXaWDxGR/Wzx2agyGpnI67jlCnqpwIiS4Vw8gaiXyZQ0NFcdjloPljIksOJdvBKbyU54dATrxDBbl/uZeH8Ii2ycHzAy7SCnxrDV1+JpcuNpWsgas4vVzR58Zh2PRcZtcXEwkmbvpTAnx89RbTJTa6/CmSvjDAT5XJeNmhoTSxcvJplIcb5SxohGu9OFLTuDLxicH7CkzcWuPUkeWp6i4ISNdwRpleGiquG3//2lSWtg0FTuaXETrK1iPBbBJJcZ+OMOcm4Jz50rWBBN0N97gOFJBaxGziolTh36K952P9t/9hK9O568NnPOt+Chbo31C3P0nowwdvwgw/0HAfDbJc7PTHMiPMrgxCUS6QksWhTTxCmSR9/AW46TS01xsrefmGTn5cE4v9l/hC5/E2va/bi0PL1Xpui6/8vcvuKO+RMYn6lgb7DiEl3MTIzy/rF9JAUno+EoRitk1RSyJKMW4cLwOS5fGOHSmQEuTMVJjMVZoI3TmUtxFJ0PbF6WZ8sc372bRD7Hhs2Pg6OeJ55+hs75ABdjEsqZMJtuayXU2EnkisLgid9yZKyEu6UVJRpmamoaOREnl81QyitYLLMMj/bTLeTp8YoMpSQCDRWe3f5T3HmRwTf30PrwN7CvfQBRVaG1jcrxQ3MBqSz4gHryDF5O0DddQauWyGdFOhbXcV+TyOi0wqoHHyU1dpHca9/FbpxFafTiWfsoCw0S+tkRXt7xJ9L5cVRFJRrOcPfd62j98U8YW7eF8QujeBs9CNVOTh2fJ4FSEaYLFUq5FNNDKbJ5ndd3HCOXyZDJqjxs97F2Yw/j6RjlQhZbi58el4+Jd3tZ3l6LZ/tLbH3uR1yOnuaFF19kw4JGfh5SWbMwSldjLZl0moKS/DfvQFLjw8FJ1gbbMPi9ZIpl2gs6V2JGXFYfZyejqANnsK37Gka7DVtjIzvfeIeR3+3C9Ng99PRswuNvJXz+NAtaGhiT3Sy9Pcgip5FEtojZYMSiF+YHBILL6L73Ef4yfBa7u4ZJdRpDV5CGWyuUDBYK6SgDb/+BoqkaYzEFx04zc36UTRtWsjLYydDRAyxrdDJkNfHYVzezeGkHq5Z1ELoQRRQE2uocTMyk5wd0tjbz7JNPcKSvD7PZSCqVhoqOQRYp53PIWhmtVMIgCMiCTlnT0Y0PYLRa6E+HiR3YxypJonvb11mxeg1WTUdRs2Rm83S11FERBRRFmR/wy6dWX1t/1Dk3NMhxfc0AuK82H+Od7ffO2T9zg545gMFjszc84LDO0/kplfDZr9lngJsN+Bveb9bpS0UiAAAAAABJRU5ErkJggg=='
            }
            imageSize={`${imageSize}px`}
            onClick={onClick ? () => 'false' : ''}
          >
            {!vertical3 && (
              <ImageButton.Item
                bold
                width={'64px'}
                selected={disabled}
                content={itemContent}
                tooltip="Click to disable main button"
                tooltipPosition="bottom-end"
                icon={itemIcon}
                iconColor={'gold'}
                iconSize={itemIconSize}
                iconPosition={itemIconPos}
                onClick={toggleDisabled}
              />
            )}
          </ImageButton>
        </Stack.Item>
      </Section>
      <Section
        title="Color States"
        buttons={<Button.Checkbox content="Vertical" checked={vertical1} onClick={toggleVertical1} />}
      >
        {COLORS_STATES.map((color) => (
          <ImageButton
            m={vertical1 ? 0.5 : 0}
            vertical={vertical1}
            key={color}
            color={color}
            content={color}
            image={
              'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAOVBMVEXAwMDBr16vk0uORiz/o7HyfxiZbDXWzMzhbA3//wD////tHCQAAP/4ior/ADOAgIDAwMAAAAAzmQDdkuRxAAAAAXRSTlMAQObYZgAAAKxJREFUOI3dksESgyAMRG0FE4I22P//2IaAVdB0em3Xy477SJYZhuFfdDO1AXdD4xtwRd77o5t6wKt20wPlN2QVewUgQqAAiD0QYxQCJYc5zCAEtisUcBkgmUAZ6ErGWh9oeSwE6k+3yHNACIIPgMzQONsWYOZ90QXAiRK7g2K7gtNKayXKjdoOcv4pX+IcGoBMqIA26TswSU6HmueSpLlRcjK0AaOpL97rb+gFHckLe1QlljQAAAAASUVORK5CYII='
            }
            imageSize={vertical1 ? '48px' : '24px'}
            onClick={onClick ? () => 'false' : ''}
          />
        ))}
      </Section>
      <Section
        title="Available Colors"
        buttons={<Button.Checkbox content="Vertical" checked={vertical2} onClick={toggleVertical2} />}
      >
        {COLORS_SPECTRUM.map((color) => (
          <ImageButton
            m={vertical2 ? 0.5 : 0}
            vertical={vertical2}
            key={color}
            color={color}
            content={color}
            image={
              'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAAJ1BMVEUAAABeGFCgXZN2PnKqqqq/vr/T09PycWFIHUFeKlNLHEtVWWOOj5g02k6OAAAAAXRSTlMAQObYZgAAAFdJREFUKJFjYBhEgFEQDATgAkImLkDgrIgQME0vSy8LRhYoBwISBdLLy1HNSCsvT0MWwLDWGAwQAp0rZ+3evXLWDGSBM2dQBWYCAUkCHB1g0IAreAYCAACm2zDykxPL4AAAAABJRU5ErkJggg=='
            }
            imageSize={vertical2 ? '48px' : '24px'}
            onClick={onClick ? () => 'false' : ''}
          />
        ))}
      </Section>
    </>
  );
};
