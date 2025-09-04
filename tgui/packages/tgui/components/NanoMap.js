import { Component, createContext, useContext } from 'react';
import { Box, Button, Flex, Icon, LabeledList, Slider, Tooltip } from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';

const MapContext = createContext({ zoom: 1 });
const MAP_SIZE = 510;
/** At zoom = 1 */
const PIXELS_PER_TURF = 2;

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
      offsetX: props.offsetX ?? 0,
      offsetY: props.offsetY ?? 0,
      dragging: false,
      originX: null,
      originY: null,
      zoom: props.zoom ?? 1,
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
          state.offsetX += newOffsetX / state.zoom;
          state.offsetY += newOffsetY / state.zoom;
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
      props.onOffsetChange?.(e, this.state);
      pauseEvent(e);
    };

    this.handleZoom = (_e, value) => {
      this.setState((state) => {
        const newZoom = Math.min(Math.max(value, 1), 8);
        state.zoom = newZoom;
        if (props.onZoom) {
          props.onZoom(state.zoom);
        }
        return state;
      });
    };

    this.handleReset = (e) => {
      this.setState((state) => {
        state.offsetX = 0;
        state.offsetY = 0;
        state.zoom = 1;
        this.handleZoom(e, 1);
        props.onOffsetChange?.(e, state);
      });
    };
  }

  render() {
    const { config } = useBackend();
    const { dragging, offsetX, offsetY, zoom = 1 } = this.state;
    const { children } = this.props;

    const mapUrl = config.map + '_nanomap_z1.png';
    const mapSize = MAP_SIZE * zoom + 'px';
    const newStyle = {
      width: mapSize,
      height: mapSize,
      marginTop: offsetY * zoom + 'px',
      marginLeft: offsetX * zoom + 'px',
      overflow: 'hidden',
      position: 'relative',
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      backgroundSize: 'cover',
      backgroundRepeat: 'no-repeat',
      textAlign: 'center',
      cursor: dragging ? 'move' : 'auto',
    };
    const mapStyle = {
      width: '100%',
      height: '100%',
      position: 'absolute',
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      imageRendering: 'pixelated',
    };

    return (
      <MapContext.Provider value={{ zoom }}>
        <Box className="NanoMap__container">
          <Box style={newStyle} onMouseDown={this.handleDragStart}>
            <img src={resolveAsset(mapUrl)} style={mapStyle} />
            <Box>{children}</Box>
          </Box>
          <NanoMapZoomer zoom={zoom} onZoom={this.handleZoom} onReset={this.handleReset} />
        </Box>
      </MapContext.Provider>
    );
  }
}

const NanoMapMarker = (props) => {
  const { zoom } = useContext(MapContext);
  const { x, y, icon, tooltip, color, children, ...rest } = props;
  const pixelsPerTurfAtZoom = PIXELS_PER_TURF * zoom;
  // For some reason the X and Y are offset by 1
  const rx = (x - 1) * pixelsPerTurfAtZoom;
  const ry = (y - 1) * pixelsPerTurfAtZoom;
  return (
    <div>
      <Tooltip content={tooltip}>
        <Box
          position="absolute"
          className="NanoMap__marker"
          lineHeight="0"
          bottom={ry + 'px'}
          left={rx + 'px'}
          width={pixelsPerTurfAtZoom + 'px'}
          height={pixelsPerTurfAtZoom + 'px'}
          {...rest}
        >
          {children}
        </Box>
      </Tooltip>
    </div>
  );
};

NanoMap.Marker = NanoMapMarker;

const NanoMapMarkerIcon = (props) => {
  const { zoom } = useContext(MapContext);
  const { icon, color, ...rest } = props;
  const markerSize = PIXELS_PER_TURF * zoom + 4 / Math.ceil(zoom / 4);
  return (
    <NanoMapMarker {...rest}>
      <Icon
        name={icon}
        color={color}
        fontSize={`${markerSize}px`}
        style={{
          position: 'relative',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
        }}
      />
    </NanoMapMarker>
  );
};

NanoMap.MarkerIcon = NanoMapMarkerIcon;

const NanoMapZoomer = (props) => {
  return (
    <Box className="NanoMap__zoomer">
      <LabeledList>
        <LabeledList.Item label="Zoom" verticalAlign="middle">
          <Flex direction="row">
            <Slider
              minValue={1}
              maxValue={8}
              stepPixelSize={10}
              format={(v) => v + 'x'}
              value={props.zoom}
              tickWhileDragging
              onChange={(e, v) => props.onZoom(e, v)}
            />
            <Button
              ml="0.5em"
              style={{ float: 'right' }}
              icon="sync"
              tooltip="Reset View"
              onClick={(e) => props.onReset?.(e)}
            />
          </Flex>
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};

NanoMap.Zoomer = NanoMapZoomer;
