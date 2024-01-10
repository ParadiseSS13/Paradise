/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';
import { KEY_ENTER, KEY_ESCAPE, KEY_SPACE } from 'common/keycodes';
import { createLogger } from '../logging';
import { Box } from './Box';
import { Icon } from './Icon';
import { Tooltip } from './Tooltip';

const logger = createLogger('Button');

export const Button = (props) => {
  const {
    className,
    fluid,
    icon,
    iconRotation,
    iconSpin,
    color,
    textColor,
    disabled,
    selected,
    tooltip,
    tooltipPosition,
    ellipsis,
    compact,
    circular,
    content,
    iconColor,
    iconRight,
    iconStyle,
    children,
    onclick,
    onClick,
    multiLine,
    ...rest
  } = props;
  const hasContent = !!(content || children);
  // A warning about the lowercase onclick
  if (onclick) {
    logger.warn(
      `Lowercase 'onclick' is not supported on Button and lowercase` +
        ` prop names are discouraged in general. Please use a camelCase` +
        `'onClick' instead and read: ` +
        `https://infernojs.org/docs/guides/event-handling`
    );
  }
  rest.onClick = (e) => {
    if (!disabled && onClick) {
      onClick(e);
    }
  };
  // IE8: Use "unselectable" because "user-select" doesn't work.
  if (Byond.IS_LTE_IE8) {
    rest.unselectable = true;
  }
  let buttonContent = (
    <Box
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        disabled && 'Button--disabled',
        selected && 'Button--selected',
        hasContent && 'Button--hasContent',
        ellipsis && 'Button--ellipsis',
        circular && 'Button--circular',
        compact && 'Button--compact',
        iconRight && 'Button--iconRight',
        multiLine && 'Button--multiLine',
        color && typeof color === 'string'
          ? 'Button--color--' + color
          : 'Button--color--default',
        className,
      ])}
      tabIndex={!disabled && '0'}
      color={textColor}
      onKeyDown={(e) => {
        const keyCode = window.event ? e.which : e.keyCode;
        // Simulate a click when pressing space or enter.
        if (keyCode === KEY_SPACE || keyCode === KEY_ENTER) {
          e.preventDefault();
          if (!disabled && onClick) {
            onClick(e);
          }
          return;
        }
        // Refocus layout on pressing escape.
        if (keyCode === KEY_ESCAPE) {
          e.preventDefault();
          return;
        }
      }}
      {...rest}
    >
      {icon && !iconRight && (
        <Icon
          name={icon}
          color={iconColor}
          rotation={iconRotation}
          spin={iconSpin}
          style={iconStyle}
        />
      )}
      {content}
      {children}
      {icon && iconRight && (
        <Icon
          name={icon}
          color={iconColor}
          rotation={iconRotation}
          spin={iconSpin}
          style={iconStyle}
        />
      )}
    </Box>
  );

  if (tooltip) {
    buttonContent = (
      <Tooltip content={tooltip} position={tooltipPosition}>
        {buttonContent}
      </Tooltip>
    );
  }

  return buttonContent;
};

Button.defaultHooks = pureComponentHooks;

export const ButtonCheckbox = (props) => {
  const { checked, ...rest } = props;
  return (
    <Button
      color="transparent"
      icon={checked ? 'check-square-o' : 'square-o'}
      selected={checked}
      {...rest}
    />
  );
};

Button.Checkbox = ButtonCheckbox;

export class ButtonConfirm extends Component {
  constructor() {
    super();
    this.state = {
      clickedOnce: false,
    };
    this.handleClick = () => {
      if (this.state.clickedOnce) {
        this.setClickedOnce(false);
      }
    };
  }

  setClickedOnce(clickedOnce) {
    this.setState({
      clickedOnce,
    });
    if (clickedOnce) {
      setTimeout(() => window.addEventListener('click', this.handleClick));
    } else {
      window.removeEventListener('click', this.handleClick);
    }
  }

  render() {
    const {
      confirmContent = 'Confirm?',
      confirmColor = 'bad',
      confirmIcon,
      icon,
      color,
      content,
      onClick,
      ...rest
    } = this.props;
    return (
      <Button
        content={this.state.clickedOnce ? confirmContent : content}
        icon={this.state.clickedOnce ? confirmIcon : icon}
        color={this.state.clickedOnce ? confirmColor : color}
        onClick={() =>
          this.state.clickedOnce ? onClick() : this.setClickedOnce(true)
        }
        {...rest}
      />
    );
  }
}

Button.Confirm = ButtonConfirm;

export class ButtonInput extends Component {
  constructor() {
    super();
    this.inputRef = createRef();
    this.state = {
      inInput: false,
    };
  }

  setInInput(inInput) {
    const { disabled } = this.props;
    if (disabled) {
      return;
    }
    this.setState({
      inInput,
    });
    if (this.inputRef) {
      const input = this.inputRef.current;
      if (inInput) {
        input.value = this.props.currentValue || '';
        try {
          input.focus();
          input.select();
        } catch {}
      }
    }
  }

  commitResult(e) {
    if (this.inputRef) {
      const input = this.inputRef.current;
      const hasValue = input.value !== '';
      if (hasValue) {
        this.props.onCommit(e, input.value);
        return;
      } else {
        if (!this.props.defaultValue) {
          return;
        }
        this.props.onCommit(e, this.props.defaultValue);
      }
    }
  }

  render() {
    const {
      fluid,
      content,
      icon,
      iconRotation,
      iconSpin,
      tooltip,
      tooltipPosition,
      color = 'default',
      disabled,
      placeholder,
      maxLength,
      multiLine,
      ...rest
    } = this.props;

    let buttonContent = (
      <Box
        className={classes([
          'Button',
          fluid && 'Button--fluid',
          disabled && 'Button--disabled',
          'Button--color--' + color,
          multiLine + 'Button--multiLine',
        ])}
        {...rest}
        onClick={() => this.setInInput(true)}
      >
        {icon && <Icon name={icon} rotation={iconRotation} spin={iconSpin} />}
        <div>{content}</div>
        <input
          ref={this.inputRef}
          className="NumberInput__input"
          style={{
            'display': !this.state.inInput ? 'none' : undefined,
            'text-align': 'left',
          }}
          onBlur={(e) => {
            if (!this.state.inInput) {
              return;
            }
            this.setInInput(false);
            this.commitResult(e);
          }}
          onKeyDown={(e) => {
            if (e.keyCode === KEY_ENTER) {
              this.setInInput(false);
              this.commitResult(e);
              return;
            }
            if (e.keyCode === KEY_ESCAPE) {
              this.setInInput(false);
            }
          }}
        />
      </Box>
    );

    if (tooltip) {
      buttonContent = (
        <Tooltip content={tooltip} position={tooltipPosition}>
          {buttonContent}
        </Tooltip>
      );
    }

    return buttonContent;
  }
}

Button.Input = ButtonInput;
