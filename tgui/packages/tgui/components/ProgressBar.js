import { clamp01, keyOfMatchingRange, scale, toFixed } from 'common/math';
import { classes, pureComponentHooks } from 'common/react';
import { Component } from 'inferno';
import { computeBoxClassName, computeBoxProps } from './Box';

export const ProgressBar = props => {
  const {
    className,
    value,
    minValue = 0,
    maxValue = 1,
    color,
    ranges = {},
    children,
    ...rest
  } = props;
  const scaledValue = scale(value, minValue, maxValue);
  const hasContent = children !== undefined;
  const effectiveColor = color
    || keyOfMatchingRange(value, ranges)
    || 'default';
  return (
    <div
      className={classes([
        'ProgressBar',
        'ProgressBar--color--' + effectiveColor,
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}>
      <div
        className="ProgressBar__fill ProgressBar__fill--animated"
        style={{
          width: clamp01(scaledValue) * 100 + '%',
        }} />
      <div className="ProgressBar__content">
        {hasContent
          ? children
          : toFixed(scaledValue * 100) + '%'}
      </div>
    </div>
  );
};

ProgressBar.defaultHooks = pureComponentHooks;

export class ProgressBarCountdown extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      value: Math.max(props.current * 100, 0), // ds -> ms
    };
  }

  tick() {
    const newValue = Math.max(this.state.value + this.props.rate, 0);
    if (newValue <= 0) {
      clearInterval(this.timer);
    }
    this.setState(prevState => {
      return {
        value: newValue,
      };
    });
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), this.props.rate);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  render() {
    const {
      start,
      current,
      end,
      ...rest
    } = this.props;
    const frac = (this.state.value / 100 - start) / (end - start);
    return (
      <ProgressBar
        value={frac}
        {...rest}
      />
    );
  }
}

ProgressBarCountdown.defaultProps = {
  rate: 1000,
};

ProgressBar.Countdown = ProgressBarCountdown;
