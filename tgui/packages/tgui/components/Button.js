import { classes, pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';
import { IS_IE8 } from '../byond';
import { KEY_ENTER, KEY_ESCAPE, KEY_SPACE } from '../hotkeys';
import { refocusLayout } from '../layouts';
import { createLogger } from '../logging';
import { Box } from './Box';
import { Icon } from './Icon';
import { Tooltip } from './Tooltip';

const logger = createLogger('Button');

export const Button = props => {
  const {
    className,
    fluid,
    icon,
    color,
    disabled,
    selected,
    tooltip,
    tooltipPosition,
    ellipsis,
    content,
    iconRotation,
    iconColor,
    iconSpin,
    iconRight,
    children,
    onclick,
    onClick,
    ...rest
  } = props;
  const hasContent = !!(content || children);
  // A warning about the lowercase onclick
  if (onclick) {
    logger.warn(
      `Lowercase 'onclick' is not supported on Button and lowercase`
      + ` prop names are discouraged in general. Please use a camelCase`
      + `'onClick' instead and read: `
      + `https://infernojs.org/docs/guides/event-handling`);
  }
  // IE8: Use a lowercase "onclick" because synthetic events are fucked.
  // IE8: Use an "unselectable" prop because "user-select" doesn't work.
  return (
    <Box
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        disabled && 'Button--disabled',
        selected && 'Button--selected',
        hasContent && 'Button--hasContent',
        ellipsis && 'Button--ellipsis',
        iconRight && 'Button--iconRight',
        (color && typeof color === 'string')
          ? 'Button--color--' + color
          : 'Button--color--default',
        className,
      ])}
      tabIndex={!disabled && '0'}
      unselectable={IS_IE8}
      onclick={e => {
        refocusLayout();
        if (!disabled && onClick) {
          onClick(e);
        }
      }}
      onKeyDown={e => {
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
          refocusLayout();
          return;
        }
      }}
      {...rest}>
      {(icon && !iconRight) && (
        <Icon name={icon}
          color={iconColor}
          rotation={iconRotation}
          spin={iconSpin} />
      )}
      {content}
      {children}
      {(icon && iconRight) && (
        <Icon name={icon}
          color={iconColor}
          rotation={iconRotation}
          spin={iconSpin} />
      )}
      {tooltip && (
        <Tooltip
          content={tooltip}
          position={tooltipPosition} />
      )}
    </Box>
  );
};

Button.defaultHooks = pureComponentHooks;

export const ButtonCheckbox = props => {
  const { checked, ...rest } = props;
  return (
    <Button
      color="transparent"
      icon={checked ? 'check-square-o' : 'square-o'}
      selected={checked}
      {...rest} />
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
    }
    else {
      window.removeEventListener('click', this.handleClick);
    }
  }

  render() {
    const {
      confirmContent = "Confirm?",
      confirmColor = "bad",
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
        onClick={() => this.state.clickedOnce
          ? onClick()
          : this.setClickedOnce(true)}
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
    this.setState({
      inInput,
    });
    if (this.inputRef) {
      const input = this.inputRef.current;
      if (inInput) {
        input.value = this.props.currentValue || "";
        try {
          input.focus();
          input.select();
        }
        catch {}
      }
    }
  }

  commitResult(e) {
    if (this.inputRef) {
      const input = this.inputRef.current;
      const hasValue = (input.value !== "");
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
      placeholder,
      maxLength,
      ...rest
    } = this.props;

    return (
      <Box
        className={classes([
          'Button',
          fluid && 'Button--fluid',
          'Button--color--' + color,
        ])}
        {...rest}
        onClick={() => this.setInInput(true)}>
        {icon && (
          <Icon name={icon} rotation={iconRotation} spin={iconSpin} />
        )}
        <div>
          {content}
        </div>
        <input
          ref={this.inputRef}
          className="NumberInput__input"
          style={{
            'display': !this.state.inInput ? 'none' : undefined,
            'text-align': 'left',
          }}
          onBlur={e => {
            if (!this.state.inInput) {
              return;
            }
            this.setInInput(false);
            this.commitResult(e);
          }}
          onKeyDown={e => {
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
        {tooltip && (
          <Tooltip
            content={tooltip}
            position={tooltipPosition}
          />
        )}
      </Box>
    );
  }
}

Button.Input = ButtonInput;
