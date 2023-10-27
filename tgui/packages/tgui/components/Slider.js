import { clamp01, keyOfMatchingRange, scale } from 'common/math';
import { classes } from 'common/react';
import { IS_IE8 } from '../byond';
import { computeBoxClassName, computeBoxProps } from './Box';
import { DraggableControl } from './DraggableControl';
import { NumberInput } from './NumberInput';

export const Slider = (props) => {
  // IE8: I don't want to support a yet another component on IE8.
  if (IS_IE8) {
    return <NumberInput {...props} />;
  }
  const {
    // Draggable props (passthrough)
    animated,
    format,
    maxValue,
    minValue,
    onChange,
    onDrag,
    step,
    stepPixelSize,
    suppressFlicker,
    unit,
    value,
    // Own props
    className,
    fillValue,
    color,
    ranges = {},
    children,
    disabled,
    ...rest
  } = props;
  const hasContent = children !== undefined;
  return (
    <DraggableControl
      dragMatrix={[1, 0]}
      {...{
        animated,
        format,
        maxValue,
        minValue,
        onChange,
        onDrag,
        step,
        stepPixelSize,
        suppressFlicker,
        unit,
        value,
        disabled,
      }}
    >
      {(control) => {
        const {
          dragging,
          editing,
          value,
          displayValue,
          displayElement,
          inputElement,
          handleDragStart,
        } = control;
        const hasFillValue = fillValue !== undefined && fillValue !== null;
        const scaledValue = scale(value, minValue, maxValue);
        const scaledFillValue = scale(
          fillValue ?? displayValue,
          minValue,
          maxValue
        );
        const scaledDisplayValue = scale(displayValue, minValue, maxValue);
        const effectiveColor =
          color || keyOfMatchingRange(fillValue ?? value, ranges) || 'default';
        return (
          <div
            className={classes([
              'Slider',
              disabled && 'Slider__disabled',
              'ProgressBar',
              disabled
                ? 'ProgressBar--color--disabled'
                : 'ProgressBar--color--' + effectiveColor,
              className,
              computeBoxClassName(rest),
            ])}
            // Added for the sake of backward compatibility.
            // Inferno ignores clicks inside elements marked with disabled
            disabled={disabled}
            {...computeBoxProps(rest)}
            onMouseDown={handleDragStart}
          >
            <div
              className={classes([
                'ProgressBar__fill',
                hasFillValue && 'ProgressBar__fill--animated',
              ])}
              style={{
                width: clamp01(scaledFillValue) * 100 + '%',
                opacity: 0.4,
              }}
            />
            <div
              className="ProgressBar__fill"
              style={{
                width:
                  clamp01(Math.min(scaledFillValue, scaledDisplayValue)) * 100 +
                  '%',
              }}
            />
            <div
              className="Slider__cursorOffset"
              style={{
                width: clamp01(scaledDisplayValue) * 100 + '%',
              }}
            >
              <div className="Slider__cursor" />
              <div className="Slider__pointer" />
              {dragging && (
                <div className="Slider__popupValue">{displayElement}</div>
              )}
            </div>
            <div className="ProgressBar__content">
              {hasContent ? children : displayElement}
            </div>
            {inputElement}
          </div>
        );
      }}
    </DraggableControl>
  );
};
