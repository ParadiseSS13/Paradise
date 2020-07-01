import { shallowDiffers } from 'common/react';
import { debounce } from 'common/timer';
import { Component, createRef } from 'inferno';
import { callByond, IS_IE8 } from '../byond';
import { createLogger } from '../logging';
import { computeBoxProps } from './Box';

const logger = createLogger('ByondUi');

// Stack of currently allocated BYOND UI element ids.
const byondUiStack = [];

const createByondUiElement = elementId => {
  // Reserve an index in the stack
  const index = byondUiStack.length;
  byondUiStack.push(null);
  // Get a unique id
  const id = elementId || 'byondui_' + index;
  logger.log(`allocated '${id}'`);
  // Return a control structure
  return {
    render: params => {
      logger.log(`rendering '${id}'`);
      byondUiStack[index] = id;
      callByond('winset', {
        ...params,
        id,
      });
    },
    unmount: () => {
      logger.log(`unmounting '${id}'`);
      byondUiStack[index] = null;
      callByond('winset', {
        id,
        parent: '',
      });
    },
  };
};

window.addEventListener('beforeunload', () => {
  // Cleanly unmount all visible UI elements
  for (let index = 0; index < byondUiStack.length; index++) {
    const id = byondUiStack[index];
    if (typeof id === 'string') {
      logger.log(`unmounting '${id}' (beforeunload)`);
      byondUiStack[index] = null;
      callByond('winset', {
        id,
        parent: '',
      });
    }
  }
});

/**
 * Get the bounding box of the DOM element.
 */
const getBoundingBox = element => {
  const rect = element.getBoundingClientRect();
  return {
    pos: [
      rect.left,
      rect.top,
    ],
    size: [
      rect.right - rect.left,
      rect.bottom - rect.top,
    ],
  };
};

export class ByondUi extends Component {
  constructor(props) {
    super(props);
    this.containerRef = createRef();
    this.byondUiElement = createByondUiElement(props.params?.id);
    this.handleResize = debounce(() => {
      this.forceUpdate();
    }, 500);
  }

  shouldComponentUpdate(nextProps) {
    const {
      params: prevParams = {},
      ...prevRest
    } = this.props;
    const {
      params: nextParams = {},
      ...nextRest
    } = nextProps;
    return shallowDiffers(prevParams, nextParams)
      || shallowDiffers(prevRest, nextRest);
  }

  componentDidMount() {
    // IE8: It probably works, but fuck you anyway.
    if (IS_IE8) {
      return;
    }
    window.addEventListener('resize', this.handleResize);
    return this.componentDidUpdate();
  }

  componentDidUpdate() {
    // IE8: It probably works, but fuck you anyway.
    if (IS_IE8) {
      return;
    }
    const {
      params = {},
    } = this.props;
    const box = getBoundingBox(this.containerRef.current);
    logger.log('bounding box', box);
    this.byondUiElement.render({
      ...params,
      pos: box.pos[0] + ',' + box.pos[1],
      size: box.size[0] + 'x' + box.size[1],
    });
  }

  componentWillUnmount() {
    // IE8: It probably works, but fuck you anyway.
    if (IS_IE8) {
      return;
    }
    window.removeEventListener('resize', this.handleResize);
    this.byondUiElement.unmount();
  }

  render() {
    const {
      parent,
      params,
      ...rest
    } = this.props;
    const type = params?.type;
    const boxProps = computeBoxProps(rest);
    return (
      <div
        ref={this.containerRef}
        {...boxProps}>
        {type === 'button' && <ButtonMock />}
      </div>
    );
  }
}

const ButtonMock = () => (
  <div
    style={{
      'min-height': '22px',
    }} />
);
