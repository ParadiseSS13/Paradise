/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { useDispatch } from 'common/redux';
import { decodeHtmlEntities, toTitleCase } from 'common/string';
import { Component } from 'inferno';
import { backendSuspendStart, useBackend } from '../backend';
import { Icon } from '../components';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from '../constants';
import { useDebug } from '../debug';
import { toggleKitchenSink } from '../debug/actions';
import { dragStartHandler, recallWindowGeometry, resizeStartHandler, setWindowKey } from '../drag';
import { createLogger } from '../logging';
import { Layout } from './Layout';

const logger = createLogger('Window');

const DEFAULT_SIZE = [400, 600];

export class Window extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isReadyToRender: false,
    };
  }

  componentDidMount() {
    const { suspended } = useBackend(this.context);

    // We need to set the window to be invisible before we can set its geometry
    // Otherwise, we get a flicker effect when the window is first rendered
    Byond.winset(Byond.windowId, {
      'is-visible': false,
    });

    this.setState({ isReadyToRender: true }, () => {
      if (!suspended) {
        logger.log('mounting');
        this.updateGeometry();

        // Set can-close property
        const { canClose = true } = this.props;
        Byond.winset(Byond.windowId, {
          'can-close': Boolean(canClose),
        });
      }
    });
  }

  componentDidUpdate(prevProps, prevState) {
    const { suspended } = useBackend(this.context);
    const { config } = useBackend(this.context);
    const { width, height } = this.props;
    const { isReadyToRender } = this.state;

    // Update geometry if dimensions change or scale changes
    const shouldUpdateGeometry =
      width !== prevProps.width ||
      height !== prevProps.height ||
      (config.window?.scale !== undefined && config.window.scale !== prevProps.config?.window?.scale);

    if (!suspended && isReadyToRender && shouldUpdateGeometry) {
      this.updateGeometry();
    }
  }

  componentWillUnmount() {
    logger.log('unmounting');
  }

  updateGeometry() {
    const { config } = useBackend(this.context);
    const options = {
      size: DEFAULT_SIZE,
      ...config.window,
    };

    if (this.props.width && this.props.height) {
      options.size = [this.props.width, this.props.height];
    }

    if (config.window?.key) {
      setWindowKey(config.window.key);
    }

    recallWindowGeometry(options);

    // Make window visible after geometry has been set
    Byond.winset(Byond.windowId, {
      'is-visible': true,
    });
    logger.log('set to visible');
  }

  render() {
    const { theme, title, children, buttons, canClose = true } = this.props;
    const { config, suspended } = useBackend(this.context);
    const { debugLayout } = useDebug(this.context);
    const dispatch = useDispatch(this.context);
    const fancy = config.window?.fancy;

    // Determine when to show dimmer
    const showDimmer =
      config.user && (config.user.observer ? config.status < UI_DISABLED : config.status < UI_INTERACTIVE);

    if (suspended) {
      return null;
    }

    return (
      <Layout className="Window" theme={theme}>
        <TitleBar
          className="Window__titleBar"
          title={title || decodeHtmlEntities(config.title)}
          status={config.status}
          fancy={fancy}
          onDragStart={dragStartHandler}
          onClose={() => {
            logger.log('pressed close');
            dispatch(backendSuspendStart());
          }}
          canClose={canClose}
        >
          {buttons}
        </TitleBar>
        <div className={classes(['Window__rest', debugLayout && 'debug-layout'])}>
          {!suspended && children}
          {showDimmer && <div className="Window__dimmer" />}
        </div>
        {fancy && (
          <>
            <div className="Window__resizeHandle__e" onMouseDown={resizeStartHandler(1, 0)} />
            <div className="Window__resizeHandle__s" onMouseDown={resizeStartHandler(0, 1)} />
            <div className="Window__resizeHandle__se" onMouseDown={resizeStartHandler(1, 1)} />
          </>
        )}
      </Layout>
    );
  }
}

const WindowContent = (props) => {
  const { className, fitted, children, ...rest } = props;
  return (
    <Layout.Content className={classes(['Window__content', className])} {...rest}>
      {(fitted && children) || <div className="Window__contentPadding">{children}</div>}
    </Layout.Content>
  );
};

Window.Content = WindowContent;

const statusToColor = (status) => {
  switch (status) {
    case UI_INTERACTIVE:
      return 'good';
    case UI_UPDATE:
      return 'average';
    case UI_DISABLED:
    default:
      return 'bad';
  }
};

const TitleBar = (props, context) => {
  const { className, title, status, fancy, onDragStart, onClose } = props;
  const dispatch = useDispatch(context);
  return (
    <div className={classes(['TitleBar', className])}>
      {(status === undefined && <Icon className="TitleBar__statusIcon" name="tools" opacity={0.5} />) || (
        <Icon className="TitleBar__statusIcon" color={statusToColor(status)} name="eye" />
      )}
      <div className="TitleBar__title">
        {(typeof title === 'string' && title === title.toLowerCase() && toTitleCase(title)) || title}
      </div>
      <div className="TitleBar__dragZone" onMousedown={(e) => fancy && onDragStart(e)} />
      {process.env.NODE_ENV !== 'production' && (
        <div className="TitleBar__devBuildIndicator" onClick={() => dispatch(toggleKitchenSink())}>
          <Icon name="bug" />
        </div>
      )}
      {!!fancy && (
        <div
          className="TitleBar__close TitleBar__clickable"
          // IE8: Synthetic onClick event doesn't work on IE8.
          // IE8: Use a plain character instead of a unicode symbol.

          onclick={onClose}
        >
          ×
        </div>
      )}
    </div>
  );
};
