import { Component } from 'inferno';
import { Box, Icon, Tooltip, Button } from '.';
import { useBackend } from '../backend';
import { LabeledList } from './LabeledList';
import { Slider } from './Slider';
import { getBoundingBox } from "./ByondUi";

const pauseEvent = (e) => {
  if (e.stopPropagation) {
    e.stopPropagation();
  }
  if (e.preventDefault) {
    e.preventDefault();
  }
  e.cancelBubble = true;
  e.returnValue = false;
  return false;
};

export class NanoMap extends Component {
  constructor(props) {
    super(props);

    // Auto center based on window size
    const Xcenter = window.innerWidth / 2 - 256;
    const Ycenter = window.innerHeight / 2 - 256;

    this.state = {
      offsetX: Xcenter,
      offsetY: Ycenter,
      transform: 'none',
      dragging: false,
      originX: null,
      originY: null,
      zoom: 1,
    };

    // Dragging
    this.handleDragStart = (e) => {
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

    this.handleDragMove = (e) => {
      this.setState((prevState) => {
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

    this.handleDragEnd = (e) => {
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
      this.setState((state) => {
        const newZoom = Math.min(Math.max(value, 1), 8);
        const zoomDiff = newZoom / state.zoom;
        if (zoomDiff === 1) {
          return;
        }

        state.zoom = newZoom;

        const container = document.getElementsByClassName('NanoMap__container');
        if (container.length) {
          const bounds = getBoundingBox(container[0]);
          const currentCenterX = bounds.size[0] / 2 - state.offsetX;
          const currentCenterY = bounds.size[1] / 2 - state.offsetY;
          state.offsetX += currentCenterX - (currentCenterX * zoomDiff);
          state.offsetY += currentCenterY - (currentCenterY * zoomDiff);
        }

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

    const mapUrl = config.map + '_nanomap_z1.png';
    const mapSize = 510 * zoom + 'px';
    const newStyle = {
      width: mapSize,
      height: mapSize,
      'margin-top': offsetY + 'px',
      'margin-left': offsetX + 'px',
      'overflow': 'hidden',
      'position': 'relative',
      'background-image': 'url(' + mapUrl + ')',
      'background-size': 'cover',
      'background-repeat': 'no-repeat',
      'text-align': 'center',
      'cursor': dragging ? 'move' : 'auto',
    };

    return (
      <Box className="NanoMap__container">
        <Box
          style={newStyle}
          textAlign="center"
          onMouseDown={this.handleDragStart}
        >
          <Box>{children}</Box>
        </Box>
        <NanoMapZoomer zoom={zoom} onZoom={this.handleZoom} />
      </Box>
    );
  }
}

const NanoMapMarker = props => {
  const {
    x,
    y,
    zoom = 1,
    icon,
    tooltip,
    color,
    onClick,
    size = 6,
  } = props;
  const rx = x * 2 * zoom - zoom - 3;
  const ry = y * 2 * zoom - zoom - 3;
  return (
    <div>
      <Box
        position="absolute"
        className="NanoMap__marker"
        lineHeight="0"
        bottom={ry + "px"}
        left={rx + "px"}
        onClick={onClick}>
        <Icon
          name={icon}
          color={color}
          fontSize={size + "px"}
        />
        <Tooltip content={tooltip} />
      </Box>
    </div>
  );
};

let ActiveButton;
class NanoButton extends Component {
  constructor(props) {
    super(props);
    const { act } = useBackend(this.props.context);
    this.state = {
      color: this.props.color,
    };
    this.handleClick = e => {
      if (ActiveButton !== undefined) {
        ActiveButton.setState({
          color: "blue",
        });
      }
      act('switch_camera', {
        name: this.props.name,
      });
      ActiveButton = this;
      this.setState({
        color: "green",
      });
    };
  }
  render() {
    let rx = ((this.props.x * 2 * this.props.zoom) - this.props.zoom) - 3;
    let ry = ((this.props.y * 2 * this.props.zoom) - this.props.zoom) - 3;

    return (
      <Button
        key={this.props.key}
        // icon={this.props.icon}
        onClick={this.handleClick}
        position="absolute"
        className="NanoMap__button"
        lineHeight="0"

        color={this.props.status ? this.state.color : "red"}
        bottom={ry + "px"}
        left={rx + "px"}>

        <Tooltip content={this.props.tooltip} />
      </Button>
    );
  }
}
NanoMap.NanoButton = NanoButton;
NanoMap.Marker = NanoMapMarker;


const NanoMapZoomer = props => {
  return (
    <Box className="NanoMap__zoomer">
      <LabeledList>
        <LabeledList.Item label="Zoom">
          <Slider
            minValue="1"
            maxValue="8"
            stepPixelSize="10"
            format={(v) => v + 'x'}
            value={props.zoom}
            onDrag={(e, v) => props.onZoom(e, v)}
          />
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};

NanoMap.Zoomer = NanoMapZoomer;
