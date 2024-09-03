/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes, pureComponentHooks } from 'common/react';
import { Component, InfernoNode, RefObject, createRef } from 'inferno';
import { KEY_ENTER, KEY_ESCAPE, KEY_SPACE } from 'common/keycodes';
import { createLogger } from '../logging';
import { Box, BoxProps } from './Box';
import { Icon } from './Icon';
import { Tooltip } from './Tooltip';
import { Placement } from '@popperjs/core';

const logger = createLogger('Button');

export type ButtonProps = BoxProps & {
  fluid?: boolean;
  translucent?: boolean;
  icon?: string;
  iconRotation?: number;
  iconSpin?: BooleanLike;
  disabled?: BooleanLike;
  selected?: BooleanLike;
  tooltip?: InfernoNode;
  tooltipPosition?: Placement;
  ellipsis?: BooleanLike;
  compact?: BooleanLike;
  circular?: BooleanLike;
  iconRight?: BooleanLike;
  iconColor?: string;
  iconStyle?: any;
  multiLine?: BooleanLike;
  children?: InfernoNode;
  /** @deprecated Use children. */
  content?: InfernoNode;
  onClick?: (e: UIEvent) => void;
  onclick?: ButtonProps['onClick'];
};

export const Button = (props: ButtonProps) => {
  const {
    className,
    fluid,
    translucent,
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
  let buttonContent = (
    <Box
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        disabled && 'Button--disabled' + (translucent ? '--translucent' : ''),
        selected && 'Button--selected' + (translucent ? '--translucent' : ''),
        hasContent && 'Button--hasContent',
        ellipsis && 'Button--ellipsis',
        circular && 'Button--circular',
        compact && 'Button--compact',
        iconRight && 'Button--iconRight',
        multiLine && 'Button--multiLine',
        color && typeof color === 'string'
          ? 'Button--color--' + color + (translucent ? '--translucent' : '')
          : 'Button--color--default' + (translucent ? '--translucent' : ''),
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
        <Icon name={icon} color={iconColor} rotation={iconRotation} spin={iconSpin} style={iconStyle} />
      )}
      {content}
      {children}
      {icon && iconRight && (
        <Icon name={icon} color={iconColor} rotation={iconRotation} spin={iconSpin} style={iconStyle} />
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

export const ButtonCheckbox = (props: ButtonProps & { checked?: BooleanLike }) => {
  const { checked, ...rest } = props;
  return <Button color="transparent" icon={checked ? 'check-square-o' : 'square-o'} selected={checked} {...rest} />;
};

Button.Checkbox = ButtonCheckbox;

export type ButtonConfirmProps = ButtonProps & {
  confirmContent?: string;
  confirmColor?: string;
  confirmIcon?: string;
};

type ButtonConfirmState = {
  clickedOnce: boolean;
};

export class ButtonConfirm extends Component<ButtonConfirmProps, ButtonConfirmState> {
  constructor() {
    super();
    this.state = {
      clickedOnce: false,
    };
  }

  handleClick = () => {
    if (this.state.clickedOnce) {
      this.setClickedOnce(false);
    }
  };

  setClickedOnce(clickedOnce: boolean) {
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
        onClick={(e) => (this.state.clickedOnce ? onClick?.(e) : this.setClickedOnce(true))}
        {...rest}
      />
    );
  }
}

Button.Confirm = ButtonConfirm;

export type ButtonInputProps = ButtonProps & {
  currentValue?: string;
  defaultValue?: string;
  onCommit?: (e: UIEvent, value: string) => void;
};

type ButtonInputState = {
  inInput: boolean;
};

export class ButtonInput extends Component<ButtonInputProps, ButtonInputState> {
  inputRef: RefObject<HTMLInputElement>;

  constructor() {
    super();
    this.inputRef = createRef();
    this.state = {
      inInput: false,
    };
  }

  setInInput(inInput: boolean) {
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

  commitResult(e: UIEvent) {
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
