import { Component } from 'inferno';
import { Box, Icon, Tooltip } from '.';
import { useBackend } from "../backend";
import { LabeledList } from './LabeledList';
import { Slider } from './Slider';

const pauseEvent = e => {
  if (e.stopPropagation) { e.stopPropagation(); }
  if (e.preventDefault) { e.preventDefault(); }
  e.cancelBubble = true;
  e.returnValue = false;
  return false;
};

export class NanoMap extends Component {
  constructor(props) {
    super(props);

    // Auto center based on window size
    const Xcenter = (window.innerWidth / 2) - 256;
    const Ycenter = (window.innerHeight / 2) - 256;

    this.state = {
      offsetX: 128,
      offsetY: 48,
      transform: 'none',
      dragging: false,
      originX: null,
      originY: null,
      zoom: 1,
    };

    // Dragging
    this.handleDragStart = e => {
      this.ref = e.target;
      this.setState({
        dragging: false,
        originX: e.screenX,
        originY: e.screenY,
      });
      document.addEventListener('mousemove', this.handleDragMove);
      document.addEventListener('mouseup', this.handleDragEnd);
      pauseEvent(e);
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
      pauseEvent(e);
    };

    this.handleDragEnd = e => {
      this.setState({
        dragging: false,
        originX: null,
        originY: null,
      });
      document.removeEventListener('mousemove', this.handleDragMove);
      document.removeEventListener('mouseup', this.handleDragEnd);
      pauseEvent(e);
    };

    this.handleZoom = (_e, value) => {
      this.setState(state => {
        const newZoom = Math.min(Math.max(value, 1), 8);
        let zoomDiff = (newZoom - state.zoom) * 1.5;
        state.zoom = newZoom;
        state.offsetX = state.offsetX - 262 * zoomDiff;
        state.offsetY = state.offsetY - 256 * zoomDiff;
        if (props.onZoom) {
          props.onZoom(state.zoom);
        }
        return state;
      });
    };

  }

  render() {
    const { config } = useBackend(this.context);
    const { dragging, offsetX, offsetY, zoom = 1 } = this.state;
    const { children } = this.props;

    const mapUrl = config.map + "_nanomap_z1.png";
    const mapSize = (510 * zoom) + 'px';
    const newStyle = {
      width: mapSize,
      height: mapSize,
      "margin-top": offsetY + "px",
      "margin-left": offsetX + "px",
      "overflow": "hidden",
      "position": "relative",
      "background-image": "url(" + mapUrl + ")",
      "background-size": "cover",
      "background-repeat": "no-repeat",
      "text-align": "center",
      "cursor": dragging ? "move" : "auto",
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
        <NanoMapZoomer zoom={zoom} onZoom={this.handleZoom} />
      </Box>
    );
  }
}

const NanoMapMarker = (props, context) => {
  const {
    x,
    y,
    zoom = 1,
    icon,
    tooltip,
    color,
  } = props;
  const rx = ((x * 2 * zoom) - zoom) - 3;
  const ry = ((y * 2 * zoom) - zoom) - 3;
  return (
    <div>
      <Box
        position="absolute"
        className="NanoMap__marker"
        lineHeight="0"
        bottom={ry + "px"}
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

const NanoMapZoomer = (props, context) => {
  return (
    <Box className="NanoMap__zoomer">
      <LabeledList>
        <LabeledList.Item label="Zoom">
          <Slider
            minValue="1"
            maxValue="8"
            stepPixelSize="10"
            format={v => v + "x"}
            value={props.zoom}
            onDrag={(e, v) => props.onZoom(e, v)}
          />
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};

NanoMap.Zoomer = NanoMapZoomer;
