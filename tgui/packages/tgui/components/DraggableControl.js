import { clamp } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';
import { AnimatedNumber } from './AnimatedNumber';

/**
 * Reduces screen offset to a single number based on the matrix provided.
 */
const getScalarScreenOffset = (e, matrix) => {
  return e.screenX * matrix[0] + e.screenY * matrix[1];
};

export class DraggableControl extends Component {
  constructor(props) {
    super(props);
    this.inputRef = createRef();
    this.state = {
      value: props.value,
      dragging: false,
      editing: false,
      oldOffset: null,
      suppressingFlicker: false,
    };

    // Suppresses flickering while the value propagates through the backend
    this.flickerTimer = null;
    this.suppressFlicker = () => {
      const { suppressFlicker } = this.props;
      if (suppressFlicker > 0) {
        this.setState({
          suppressingFlicker: true,
        });
        clearTimeout(this.flickerTimer);
        this.flickerTimer = setTimeout(
          () =>
            this.setState({
              suppressingFlicker: false,
            }),
          suppressFlicker
        );
      }
    };

    this.handleDragStart = (e) => {
      const { value, dragMatrix, disabled } = this.props;
      const { editing } = this.state;
      if (editing || disabled) {
        return;
      }
      document.body.style['pointer-events'] = 'none';
      this.ref = e.currentTarget;
      this.setState({
        dragging: false,
        value,
      });
      this.timer = setTimeout(() => {
        this.setState({
          dragging: true,
        });
      }, 250);
      this.dragInterval = setInterval(() => {
        const { dragging, value } = this.state;
        const { onDrag } = this.props;
        if (dragging && onDrag) {
          onDrag(e, value);
        }
      }, 500);
      document.addEventListener('mousemove', this.handleDragMove);
      document.addEventListener('mouseup', this.handleDragEnd);
    };

    this.handleDragMove = (e) => {
      const { minValue, maxValue, step, dragMatrix, disabled } =
        this.props;
      if (disabled) {
        return;
      }
      const defaultStepPixelSize = this.ref.offsetWidth / ((maxValue - minValue) / step);
      let stepPixelSize = this.props.stepPixelSize ?? defaultStepPixelSize;
      if (typeof stepPixelSize === 'function') {
        stepPixelSize = stepPixelSize(defaultStepPixelSize);
      }
      this.setState((prevState) => {
        const state = { ...prevState };
        const oldOffset = prevState.oldOffset;
        const offset = getScalarScreenOffset(e, dragMatrix) - this.ref.getBoundingClientRect().left - window.screenX;
        if (prevState.dragging) {
          if (oldOffset !== undefined && oldOffset !== null && offset !== oldOffset) {
            const maxStep = maxValue / step;
            const toNearestStep = offset > oldOffset
              ? Math.floor  // Increasing
              : Math.ceil   // Decreasing
              ;
            /* ● = step, o = oldOffset, n = offset
             * There are four cases to consider for the following code:
             * Case 1: Increasing(offset > oldOffset), moving between steps
             * ●--o--n-●
             * value should not change. Since both offsets are subject to floor,
             * they have the same nearest steps and the difference cancels out,
             * leaving value the same
             * Case 2: Decreasing(offset < oldOffset), moving between steps
             * ●--n--o-●
             * Same as Case 1 except the function is ceil not floor
             * Case 3: Increasing, offset is past step
             * ●-o-●-n-● ; ●-o-●---●-n
             * value should increase by 1, or however many steps o is behind n
             * Case 4: Decreasing, offset is behind step
             * ●-n-●-o-● ; ●-n-●---●-o
             * Same as Case 3, but decrease instead of increase
            */
            const oldStep = clamp(toNearestStep(oldOffset / stepPixelSize), 0, maxStep);
            const newStep = clamp(toNearestStep(offset / stepPixelSize), 0, maxStep);
            const stepDifference = newStep - oldStep;
            state.value = clamp(state.value + stepDifference * step, minValue, maxValue);
          }
          state.oldOffset = offset;
        } else if (Math.abs(offset) > 4) {
          state.dragging = true;
        }
        return state;
      });
    };

    this.handleDragEnd = (e) => {
      const { onChange, onDrag } = this.props;
      const { dragging, value } = this.state;
      document.body.style['pointer-events'] = 'auto';
      clearTimeout(this.timer);
      clearInterval(this.dragInterval);
      this.setState({
        dragging: false,
        editing: !dragging,
        oldOffset: null
      });
      document.removeEventListener('mousemove', this.handleDragMove);
      document.removeEventListener('mouseup', this.handleDragEnd);
      if (dragging) {
        this.suppressFlicker();
        if (onChange) {
          onChange(e, value);
        }
        if (onDrag) {
          onDrag(e, value);
        }
      } else if (this.inputRef) {
        const input = this.inputRef.current;
        input.value = value;
        // IE8: Dies when trying to focus a hidden element
        // (Error: Object does not support this action)
        try {
          input.focus();
          input.select();
        } catch {}
      }
    };
  }

  render() {
    const {
      dragging,
      editing,
      value: intermediateValue,
      suppressingFlicker,
    } = this.state;
    const {
      animated,
      value,
      unit,
      minValue,
      maxValue,
      format,
      onChange,
      onDrag,
      children,
      // Input props
      height,
      lineHeight,
      fontSize,
      disabled,
    } = this.props;
    let displayValue = value;
    if (dragging || suppressingFlicker) {
      displayValue = intermediateValue;
    }
    // Setup a display element
    // Shows a formatted number based on what we are currently doing
    // with the draggable surface.
    const renderDisplayElement = (value) => value + (unit ? ' ' + unit : '');
    const displayElement =
      (animated && !dragging && !suppressingFlicker && (
        <AnimatedNumber value={displayValue} format={format}>
          {renderDisplayElement}
        </AnimatedNumber>
      )) ||
      renderDisplayElement(format ? format(displayValue) : displayValue);
    // Setup an input element
    // Handles direct input via the keyboard
    const inputElement = (
      <input
        ref={this.inputRef}
        className="NumberInput__input"
        style={{
          display: !editing || disabled ? 'none' : undefined,
          height: height,
          'line-height': lineHeight,
          'font-size': fontSize,
        }}
        onBlur={(e) => {
          if (!editing) {
            return;
          }
          const value = clamp(e.target.value, minValue, maxValue);
          this.setState({
            editing: false,
            value,
          });
          this.suppressFlicker();
          if (onChange) {
            onChange(e, value);
          }
          if (onDrag) {
            onDrag(e, value);
          }
        }}
        onKeyDown={(e) => {
          if (e.keyCode === 13) {
            const value = clamp(e.target.value, minValue, maxValue);
            this.setState({
              editing: false,
              value,
            });
            this.suppressFlicker();
            if (onChange) {
              onChange(e, value);
            }
            if (onDrag) {
              onDrag(e, value);
            }
            return;
          }
          if (e.keyCode === 27) {
            this.setState({
              editing: false,
            });
            return;
          }
        }}
        disabled={disabled}
      />
    );
    // Return a part of the state for higher-level components to use.
    return children({
      dragging,
      editing,
      value,
      displayValue,
      displayElement,
      inputElement,
      handleDragStart: this.handleDragStart,
    });
  }
}

DraggableControl.defaultHooks = pureComponentHooks;
DraggableControl.defaultProps = {
  minValue: -Infinity,
  maxValue: +Infinity,
  step: 1,
  suppressFlicker: 50,
  dragMatrix: [1, 0],
};
