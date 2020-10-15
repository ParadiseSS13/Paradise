import { Component } from 'inferno';
import { Box } from './Box';

export class Countdown extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      value: Math.max(props.timeLeft * 100, 0), // ds -> ms
    };
  }

  tick() {
    const newValue = Math.max(this.state.value - this.props.rate, 0);
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
      format,
      ...rest
    } = this.props;
    const formatted = new Date(this.state.value).toISOString().slice(11, 19);
    return (
      <Box as="span" {...rest}>
        {format ? format(this.state.value, formatted) : formatted}
      </Box>
    );
  }
}

Countdown.defaultProps = {
  rate: 1000,
};
