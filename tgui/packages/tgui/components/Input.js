/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Component, createRef } from 'inferno';
import { Box } from './Box';
import { KEY_ESCAPE, KEY_ENTER } from 'common/keycodes';

export const toInputValue = (value) =>
  typeof value !== 'number' && typeof value !== 'string' ? '' : String(value);

export class Input extends Component {
  constructor() {
    super();
    this.inputRef = createRef();
    this.state = {
      editing: false,
    };
    this.handleInput = (e) => {
      const { editing } = this.state;
      const { onInput } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onInput) {
        onInput(e, e.target.value);
      }
    };
    this.handleFocus = (e) => {
      const { editing } = this.state;
      if (!editing) {
        this.setEditing(true);
      }
    };
    this.handleBlur = (e) => {
      const { editing } = this.state;
      const { onChange } = this.props;
      if (editing) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
      }
    };
    this.handleKeyDown = (e) => {
      const { onInput, onChange, onEnter } = this.props;
      if (e.keyCode === KEY_ENTER) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
        if (onInput) {
          onInput(e, e.target.value);
        }
        if (onEnter) {
          onEnter(e, e.target.value);
        }
        if (this.props.selfClear) {
          e.target.value = '';
        } else {
          e.target.blur();
        }
        return;
      }
      if (e.keyCode === KEY_ESCAPE) {
        this.setEditing(false);
        e.target.value = toInputValue(this.props.value);
        e.target.blur();
        return;
      }
    };
  }

  componentDidMount() {
    const nextValue = this.props.value;
    const input = this.inputRef.current;
    if (input) {
      input.value = toInputValue(nextValue);
      input.selectionStart = 0;
      input.selectionEnd = input.value.length;
    }
    if (this.props.autoFocus || this.props.autoSelect) {
      setTimeout(() => {
        input.focus();

        if (this.props.autoSelect) {
          input.select();
        }
      }, 1);
    }
  }

  componentDidUpdate(prevProps, prevState) {
    const { editing } = this.state;
    const prevValue = prevProps.value;
    const nextValue = this.props.value;
    const input = this.inputRef.current;
    if (input && !editing && prevValue !== nextValue) {
      input.value = toInputValue(nextValue);
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  render() {
    const { props } = this;
    // Input only props
    const {
      selfClear,
      onInput,
      onChange,
      onEnter,
      value,
      maxLength,
      placeholder,
      autofocus,
      disabled,
      // Multiline props
      multiline,
      cols = 32,
      rows = 4,
      ...boxProps
    } = props;
    // Box props
    const { className, fluid, monospace, ...rest } = boxProps;
    return (
      <Box
        className={classes([
          'Input',
          fluid && 'Input--fluid',
          monospace && 'Input--monospace',
          disabled && 'Input--disabled',
          className,
        ])}
        {...rest}
      >
        <div className="Input__baseline">.</div>
        {multiline ? (
          <textarea
            ref={this.inputRef}
            className="Input__textarea"
            placeholder={placeholder}
            onInput={this.handleInput}
            onFocus={this.handleFocus}
            onBlur={this.handleBlur}
            maxLength={maxLength}
            cols={cols}
            rows={rows}
            disabled={disabled}
          />
        ) : (
          <input
            ref={this.inputRef}
            className="Input__input"
            placeholder={placeholder}
            onInput={this.handleInput}
            onFocus={this.handleFocus}
            onBlur={this.handleBlur}
            onKeyDown={this.handleKeyDown}
            maxLength={maxLength}
            disabled={disabled}
          />
        )}
      </Box>
    );
  }
}
