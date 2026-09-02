/**
 * @file
 * @copyright 2023 itsmeow
 * @license MIT
 */

import { hexToHsva, HsvaColor, hsvaToHex, hsvaToHslString, hsvaToRgba, rgbaToHsva, validHex } from 'common/color';
import { ReactNode, useEffect, useState } from 'react';
import { Autofocus, Box, Input, LabeledList, NumberInput, Section, Stack, Tooltip } from 'tgui-core/components';
import { clamp } from 'tgui-core/math';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Pointer } from '../components';
import { Interaction, Interactive } from '../components/Interactive';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type ColorPickerData = {
  autofocus: boolean;
  buttons: string[];
  message: string;
  large_buttons: boolean;
  swapped_buttons: boolean;
  timeout: number;
  title: string;
  default_color: string;
};

export const ColorPickerModal = (_) => {
  const { data } = useBackend<ColorPickerData>();
  const { timeout, message, title, autofocus, default_color = '#000000' } = data;
  let [selectedColor, setSelectedColor] = useState<HsvaColor>(hexToHsva(default_color));

  return (
    <Window height={400} title={title} width={600} theme="generic">
      {!!timeout && <Loader value={timeout} />}
      <Window.Content>
        <Stack fill vertical>
          {message && (
            <Stack.Item>
              <Section fill>
                <Box color="label" overflow="hidden">
                  {message}
                </Box>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill>
              {!!autofocus && <Autofocus />}
              <ColorSelector color={selectedColor} setColor={setSelectedColor} defaultColor={default_color} />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <InputButtons input={hsvaToHex(selectedColor)} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const ColorSelector = ({
  color,
  setColor,
  defaultColor,
}: {
  color: HsvaColor;
  setColor;
  defaultColor: string;
}) => {
  const handleChange = (params: Partial<HsvaColor>) => {
    setColor((current: HsvaColor) => {
      return Object.assign({}, current, params);
    });
  };
  const rgb = hsvaToRgba(color);
  const hexColor = hsvaToHex(color);
  return (
    <Stack>
      <Stack.Item mr={2}>
        <Stack vertical>
          <Stack.Item>
            <div className="react-colorful">
              <SaturationValue hsva={color} onChange={handleChange} />
              <Hue hue={color.h} onChange={handleChange} className="react-colorful__last-control" />
            </div>
          </Stack.Item>
          <Stack.Item>
            <Box inline width="100px" height="20px" textAlign="center">
              Current
            </Box>
            <Box inline width="100px" height="20px" textAlign="center">
              Previous
            </Box>
            <br />
            <Tooltip content={hexColor} position="bottom">
              <Box inline width="100px" height="30px" backgroundColor={hexColor} />
            </Tooltip>
            <Tooltip content={defaultColor} position="bottom">
              <Box inline width="100px" height="30px" backgroundColor={defaultColor} />
            </Tooltip>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow fontSize="15px" lineHeight="24px" className="ColorPicker--Inputs">
        <LabeledList>
          <LabeledList.Item label="HEX">
            <HexColorInput
              fluid
              prefixed
              color={hsvaToHex(color).substring(1)}
              onChange={(value) => {
                setColor(hexToHsva(value));
              }}
            />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item
            label="H"
            buttons={<TextSetter value={color.h} callback={(v) => handleChange({ h: v })} max={360} unit="°" />}
          >
            <Hue hue={color.h} onChange={handleChange} />
          </LabeledList.Item>
          <LabeledList.Item
            label="S"
            buttons={<TextSetter value={color.s} callback={(v) => handleChange({ s: v })} unit="%" />}
          >
            <Saturation color={color} onChange={handleChange} />
          </LabeledList.Item>
          <LabeledList.Item
            label="V"
            buttons={<TextSetter value={color.v} callback={(v) => handleChange({ v: v })} unit="%" />}
          >
            <Value color={color} onChange={handleChange} />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item
            label="R"
            buttons={
              <TextSetter
                value={rgb.r}
                callback={(v) => {
                  rgb.r = v;
                  handleChange(rgbaToHsva(rgb));
                }}
                max={255}
              />
            }
          >
            <RGBSlider color={color} onChange={handleChange} target="r" />
          </LabeledList.Item>
          <LabeledList.Item
            label="G"
            buttons={
              <TextSetter
                value={rgb.g}
                callback={(v) => {
                  rgb.g = v;
                  handleChange(rgbaToHsva(rgb));
                }}
                max={255}
              />
            }
          >
            <RGBSlider color={color} onChange={handleChange} target="g" />
          </LabeledList.Item>
          <LabeledList.Item
            label="B"
            buttons={
              <TextSetter
                value={rgb.b}
                callback={(v) => {
                  rgb.b = v;
                  handleChange(rgbaToHsva(rgb));
                }}
                max={255}
              />
            }
          >
            <RGBSlider color={color} onChange={handleChange} target="b" />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};

const TextSetter = ({
  value,
  callback,
  min = 0,
  max = 100,
  unit,
}: {
  value: number;
  callback: any;
  min?: number;
  max?: number;
  unit?: string;
}) => {
  return (
    <NumberInput
      width="70px"
      value={Math.round(value)}
      step={1}
      minValue={min}
      maxValue={max}
      onChange={callback}
      unit={unit}
    />
  );
};

/**
 * MIT License
 * https://github.com/omgovich/react-colorful/
 *
 * Copyright (c) 2020 Vlad Shilov <omgovich@ya.ru>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

interface HexColorInputProps extends Omit<ColorInputBaseProps, 'escape' | 'validate'> {
  /** Enables `#` prefix displaying */
  prefixed?: boolean;
  /** Allows `#rgba` and `#rrggbbaa` color formats */
  alpha?: boolean;
}

/** Adds "#" symbol to the beginning of the string */
const prefix = (value: string) => '#' + value.toUpperCase();

export const HexColorInput = (props: HexColorInputProps): ReactNode => {
  const { prefixed, alpha, color, fluid, onChange, ...rest } = props;

  /** Escapes all non-hexadecimal characters including "#" */
  const escape = (value: string) => value.replace(/([^0-9A-F]+)/gi, '').substring(0, alpha ? 8 : 6);

  /** Validates hexadecimal strings */
  const validate = (value: string) => validHex(value, alpha);

  return (
    <ColorInput
      {...rest}
      fluid={fluid}
      color={color}
      escape={escape}
      validate={validate}
      format={prefixed ? prefix : undefined}
      onChange={onChange}
    />
  );
};

interface ColorInputBaseProps {
  fluid?: boolean;
  color: string;
  onChange: (newColor: string) => void;
  /** Blocks typing invalid characters and limits string length */
  escape: (value: string) => string;
  /** Checks that value is valid color string */
  validate: (value: string) => boolean;
  /** Processes value before displaying it in the input */
  format?: (value: string) => string;
}

export function ColorInput(props: ColorInputBaseProps) {
  const { fluid, color, escape, format, validate, onChange } = props;
  const [localValue, setLocalValue] = useState<string>(escape(color));

  // do not escape dirty input
  function handleChange(value: string) {
    setLocalValue(value);
  }

  // Take the color from props if the last typed color (in local state) is not valid
  function handleBlur(value: string) {
    if (!validate(value)) {
      setLocalValue(escape(color)); // return to default;
    } else {
      const escapedValue = escape(value);
      setLocalValue(escapedValue);
      onChange(escapedValue);
    }
  }

  useEffect(() => {
    if (color !== localValue) {
      setLocalValue(escape(color));
    }
  }, [color, escape]);

  return (
    <Input
      fluid={fluid}
      value={format ? format(localValue) : localValue}
      onChange={handleChange}
      onBlur={handleBlur}
      fontFamily="monospace"
    />
  );
}

const SaturationValue = ({ hsva, onChange }) => {
  const handleMove = (interaction: Interaction) => {
    onChange({
      s: interaction.left * 100,
      v: 100 - interaction.top * 100,
    });
  };

  const handleKey = (offset: Interaction) => {
    // Saturation and brightness always fit into [0, 100] range
    onChange({
      s: clamp(hsva.s + offset.left * 100, 0, 100),
      v: clamp(hsva.v - offset.top * 100, 0, 100),
    });
  };

  return (
    <div
      className="react-colorful__saturation_value"
      style={{ backgroundColor: `${hsvaToHslString({ h: hsva.h, s: 100, v: 100, a: 1 })}` }}
    >
      <Interactive
        onMove={handleMove}
        onKey={handleKey}
        aria-label="Color"
        aria-valuetext={`Saturation ${Math.round(hsva.s)}%, Brightness ${Math.round(hsva.v)}%`}
      >
        <Pointer
          className="react-colorful__saturation_value-pointer"
          top={1 - hsva.v / 100}
          left={hsva.s / 100}
          color={hsvaToHslString(hsva)}
        />
      </Interactive>
    </div>
  );
};

const Hue = ({
  className,
  hue,
  onChange,
}: {
  className?: string;
  hue: number;
  onChange: (newHue: { h: number }) => void;
}) => {
  const handleMove = (interaction: Interaction) => {
    onChange({ h: 360 * interaction.left });
  };

  const handleKey = (offset: Interaction) => {
    // Hue measured in degrees of the color circle ranging from 0 to 360
    onChange({
      h: clamp(hue + offset.left * 360, 0, 360),
    });
  };

  const nodeClassName = classes(['react-colorful__hue', className]);

  return (
    <div className={nodeClassName}>
      <Interactive
        onMove={handleMove}
        onKey={handleKey}
        aria-label="Hue"
        aria-valuenow={Math.round(hue)}
        aria-valuemax="360"
        aria-valuemin="0"
      >
        <Pointer
          className="react-colorful__hue-pointer"
          left={hue / 360}
          color={hsvaToHslString({ h: hue, s: 100, v: 100, a: 1 })}
        />
      </Interactive>
    </div>
  );
};

const Saturation = ({
  className,
  color,
  onChange,
}: {
  className?: string;
  color: HsvaColor;
  onChange: (newSaturation: { s: number }) => void;
}) => {
  const handleMove = (interaction: Interaction) => {
    onChange({ s: 100 * interaction.left });
  };

  const handleKey = (offset: Interaction) => {
    // Hue measured in degrees of the color circle ranging from 0 to 100
    onChange({
      s: clamp(color.s + offset.left * 100, 0, 100),
    });
  };

  const nodeClassName = classes(['react-colorful__saturation', className]);

  return (
    <div className={nodeClassName}>
      <Interactive
        style={{
          background: `linear-gradient(to right, ${hsvaToHslString({
            h: color.h,
            s: 0,
            v: color.v,
            a: 1,
          })}, ${hsvaToHslString({ h: color.h, s: 100, v: color.v, a: 1 })})`,
        }}
        onMove={handleMove}
        onKey={handleKey}
        aria-label="Saturation"
        aria-valuenow={Math.round(color.s)}
        aria-valuemax="100"
        aria-valuemin="0"
      >
        <Pointer
          className="react-colorful__saturation-pointer"
          left={color.s / 100}
          color={hsvaToHslString({ h: color.h, s: color.s, v: color.v, a: 1 })}
        />
      </Interactive>
    </div>
  );
};

const Value = ({
  className,
  color,
  onChange,
}: {
  className?: string;
  color: HsvaColor;
  onChange: (newValue: { v: number }) => void;
}) => {
  const handleMove = (interaction: Interaction) => {
    onChange({ v: 100 * interaction.left });
  };

  const handleKey = (offset: Interaction) => {
    onChange({
      v: clamp(color.v + offset.left * 100, 0, 100),
    });
  };

  const nodeClassName = classes(['react-colorful__value', className]);

  return (
    <div className={nodeClassName}>
      <Interactive
        style={{
          background: `linear-gradient(to right, ${hsvaToHslString({
            h: color.h,
            s: color.s,
            v: 0,
            a: 1,
          })}, ${hsvaToHslString({ h: color.h, s: color.s, v: 100, a: 1 })})`,
        }}
        onMove={handleMove}
        onKey={handleKey}
        aria-label="Value"
        aria-valuenow={Math.round(color.s)}
        aria-valuemax="100"
        aria-valuemin="0"
      >
        <Pointer
          className="react-colorful__value-pointer"
          left={color.v / 100}
          color={hsvaToHslString({ h: color.h, s: color.s, v: color.v, a: 1 })}
        />
      </Interactive>
    </div>
  );
};

const RGBSlider = ({
  className,
  color,
  onChange,
  target,
}: {
  className?: string;
  color: HsvaColor;
  onChange: (newValue: HsvaColor) => void;
  target: string;
}) => {
  const rgb = hsvaToRgba(color);

  const setNewTarget = (value: number) => {
    rgb[target] = value;
    onChange(rgbaToHsva(rgb));
  };

  const handleMove = (interaction: Interaction) => {
    setNewTarget(255 * interaction.left);
  };

  const handleKey = (offset: Interaction) => {
    setNewTarget(clamp(rgb[target] + offset.left * 255, 0, 255));
  };

  const nodeClassName = classes([`react-colorful__${target}`, className]);

  let selected =
    target === 'r'
      ? `rgb(${Math.round(rgb.r)},0,0)`
      : target === 'g'
        ? `rgb(0,${Math.round(rgb.g)},0)`
        : `rgb(0,0,${Math.round(rgb.b)})`;

  return (
    <div className={nodeClassName}>
      <Interactive
        onMove={handleMove}
        onKey={handleKey}
        aria-valuenow={rgb[target]}
        aria-valuemax="100"
        aria-valuemin="0"
      >
        <Pointer className={`react-colorful__${target}-pointer`} left={rgb[target] / 255} color={selected} />
      </Interactive>
    </div>
  );
};
