import { Box, Icon, Tooltip } from '.';
import { Component } from 'inferno';
import { useBackend } from "../backend";


export class NanoMap extends Component {
  constructor(props) {
    super(props);

    // Auto center based on window size
    let Xcenter = (window.innerWidth / 2) - 256;

    this.state = {
      offsetX: Xcenter,
      offsetY: 0,
      transform: 'none',
      dragging: false,
      originX: null,
      originY: null,
    };

    this.handleDragStart = e => {
      document.body.style['pointer-events'] = 'none';
      this.ref = e.target;
      this.setState({
        dragging: false,
        originX: e.screenX,
        originY: e.screenY,
      });
      this.timer = setTimeout(() => {
        this.setState({
          dragging: true,
        });
      }, 250);
      document.addEventListener('mousemove', this.handleDragMove);
      document.addEventListener('mouseup', this.handleDragEnd);
    };

    this.handleDragMove = e => {
      this.setState(prevState => {
        const state = { ...prevState };
        const newOffsetX = e.screenX - state.originX;
        const newOffsetY = e.screenY - state.originY;
        if (prevState.dragging) {
          state.offsetX += newOffsetX;
          state.offsetY += newOffsetY;
          state.originX = e.screenX;
          state.originY = e.screenY;
        } else {
          state.dragging = true;
        }
        return state;
      });
    };

    this.handleDragEnd = e => {
      document.body.style['pointer-events'] = 'auto';
      clearTimeout(this.timer);
      this.setState({
        dragging: false,
        originX: null,
        originY: null,
      });
      document.removeEventListener('mousemove', this.handleDragMove);
      document.removeEventListener('mouseup', this.handleDragEnd);
    };
  }

  render() {
    const { config } = useBackend(this.context);
    const { offsetX, offsetY } = this.state;
    const { children, zoom } = this.props;

    const newStyle = {
      width: '512px',
      height: '512px',
      "margin-top": offsetY + 'px',
      "margin-left": offsetX + 'px',
      "overflow": "hidden",
      "position": "relative",
      "padding": "0px",
      "background-image":
        "url(" + config.map + "_nanomap_z1.png)",
      "background-size": "cover",
      "text-align": "center",
      "transform-origin": "center center",
      "transform": "scale(" + zoom + ")",
    };

    return (
      <Box className="NanoMap__container">
        <Box
          style={newStyle}
          textAlign="center"
          onMouseDown={this.handleDragStart}>
          <Box>
            {children}
          </Box>
        </Box>
      </Box>
    );
  }
}

const NanoMapMarker = (props, context) => {
  const {
    os = context.size,
    x,
    y,
    zoom,
    icon,
    tooltip,
    color,
  } = props;
  const center = 256 * zoom;
  const rx = -256 * (zoom - 1) + x * (2 * zoom) - 1.5 * zoom - 3;
  const ry = 512 * zoom - (y * 2 * zoom) + zoom - 1.5;
  return (
    <div style={"transform: scale(" + 1 / zoom + ")"}>
      <Box
        position="absolute"
        className="NanoMap__marker"
        lineHeight="0"
        top={ry + "px"}
        left={rx + "px"}>
        <Icon
          name={icon}
          color={color}
          fontSize="6px"
        />
        <Tooltip content={tooltip} />
      </Box>
    </div>
  );
};

NanoMap.Marker = NanoMapMarker;
