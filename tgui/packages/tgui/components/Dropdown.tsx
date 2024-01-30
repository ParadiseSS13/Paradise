import { createPopper, VirtualElement } from '@popperjs/core';
import { classes } from 'common/react';
import { Component, findDOMfromVNode, InfernoNode, render } from 'inferno';
import { Box, BoxProps } from './Box';
import { Icon } from './Icon';

export interface DropdownEntry {
  displayText: string | number | InfernoNode;
  value: string | number | Enumerator;
}

type DropdownUniqueProps = {
  options: string[] | DropdownEntry[];
  icon?: string;
  iconRotation?: number;
  clipSelectedText?: boolean;
  width?: string;
  menuWidth?: string;
  over?: boolean;
  color?: string;
  nochevron?: boolean;
  displayText?: string | number | InfernoNode;
  onClick?: (event) => void;
  // you freaks really are just doing anything with this shit
  selected?: any;
  onSelected?: (selected: any) => void;
};

export type DropdownProps = BoxProps & DropdownUniqueProps;

const DEFAULT_OPTIONS = {
  placement: 'left-start',
  modifiers: [
    {
      name: 'eventListeners',
      enabled: false,
    },
  ],
};
const NULL_RECT: DOMRect = {
  width: 0,
  height: 0,
  top: 0,
  right: 0,
  bottom: 0,
  left: 0,
  x: 0,
  y: 0,
  toJSON: () => null,
} as const;

type DropdownState = {
  selected?: string;
  open: boolean;
};

const DROPDOWN_DEFAULT_CLASSNAMES = 'Layout Dropdown__menu';
const DROPDOWN_SCROLL_CLASSNAMES = 'Layout Dropdown__menu-scroll';

export class Dropdown extends Component<DropdownProps, DropdownState> {
  static renderedMenu: HTMLDivElement | undefined;
  static singletonPopper: ReturnType<typeof createPopper> | undefined;
  static currentOpenMenu: Element | undefined;
  static virtualElement: VirtualElement = {
    getBoundingClientRect: () =>
      Dropdown.currentOpenMenu?.getBoundingClientRect() ?? NULL_RECT,
  };
  menuContents: any;
  constructor(props: DropdownProps) {
    super(props);
    this.state = {
      open: false,
      selected: this.props.selected,
    };
    this.menuContents = null;
  }

  handleClick = () => {
    if (this.state.open) {
      this.setOpen(false);
    }
  };

  getDOMNode() {
    return findDOMfromVNode(this.$LI, true);
  }

  componentDidMount() {
    const domNode = this.getDOMNode();

    if (!domNode) {
      return;
    }
  }

  openMenu() {
    let renderedMenu = Dropdown.renderedMenu;
    if (renderedMenu === undefined) {
      renderedMenu = document.createElement('div');
      renderedMenu.className = DROPDOWN_DEFAULT_CLASSNAMES;
      document.body.appendChild(renderedMenu);
      Dropdown.renderedMenu = renderedMenu;
    }

    const domNode = this.getDOMNode()!;
    Dropdown.currentOpenMenu = domNode;

    renderedMenu.scrollTop = 0;
    renderedMenu.style.width =
      this.props.menuWidth ||
      // Hack, but domNode should *always* be the parent control meaning it will have width
      // @ts-ignore
      `${domNode.offsetWidth}px`;
    renderedMenu.style.opacity = '1';
    renderedMenu.style.pointerEvents = 'auto';

    // ie hack
    // ie has this bizarre behavior where focus just silently fails if the
    // element being targeted "isn't ready"
    // 400 is probably way too high, but the lack of hotloading is testing my
    // patience on tuning it
    // I'm beyond giving a shit at this point it fucking works whatever
    setTimeout(() => {
      Dropdown.renderedMenu?.focus();
    }, 400);
    this.renderMenuContent();
  }

  closeMenu() {
    if (Dropdown.currentOpenMenu !== this.getDOMNode()) {
      return;
    }

    Dropdown.currentOpenMenu = undefined;
    Dropdown.renderedMenu!.style.opacity = '0';
    Dropdown.renderedMenu!.style.pointerEvents = 'none';
  }

  componentWillUnmount() {
    this.closeMenu();
    this.setOpen(false);
  }

  renderMenuContent() {
    const renderedMenu = Dropdown.renderedMenu;
    if (!renderedMenu) {
      return;
    }
    if (renderedMenu.offsetHeight > 200) {
      renderedMenu.className = DROPDOWN_SCROLL_CLASSNAMES;
    } else {
      renderedMenu.className = DROPDOWN_DEFAULT_CLASSNAMES;
    }

    const { options = [] } = this.props;
    const ops = options.map((option) => {
      let value, displayText;

      if (typeof option === 'string') {
        displayText = option;
        value = option;
      } else if (option !== null) {
        displayText = option.displayText;
        value = option.value;
      }

      return (
        <div
          key={value}
          className={classes([
            'Dropdown__menuentry',
            this.state.selected === value && 'selected',
          ])}
          onClick={() => {
            this.setSelected(value);
          }}
        >
          {displayText}
        </div>
      );
    });

    const to_render = ops.length ? ops : 'No Options Found';

    render(
      <div>{to_render}</div>,
      renderedMenu,
      () => {
        let singletonPopper = Dropdown.singletonPopper;
        if (singletonPopper === undefined) {
          singletonPopper = createPopper(
            Dropdown.virtualElement,
            renderedMenu!,
            {
              ...DEFAULT_OPTIONS,
              placement: 'bottom-start',
            }
          );

          Dropdown.singletonPopper = singletonPopper;
        } else {
          singletonPopper.setOptions({
            ...DEFAULT_OPTIONS,
            placement: 'bottom-start',
          });

          singletonPopper.update();
        }
      },
      this.context
    );
  }

  setOpen(open: boolean) {
    this.setState((state) => ({
      ...state,
      open,
    }));
    if (open) {
      setTimeout(() => {
        this.openMenu();
        window.addEventListener('click', this.handleClick);
      });
    } else {
      this.closeMenu();
      window.removeEventListener('click', this.handleClick);
    }
  }

  setSelected(selected: string) {
    this.setState((state) => ({
      ...state,
      selected,
    }));
    this.setOpen(false);
    if (this.props.onSelected) {
      this.props.onSelected(selected);
    }
  }

  render() {
    const { props } = this;
    const {
      icon,
      iconRotation,
      iconSpin,
      clipSelectedText = true,
      color = 'default',
      dropdownStyle,
      over,
      nochevron,
      width,
      onClick,
      onSelected,
      selected,
      disabled,
      displayText,
      ...boxProps
    } = props;
    const { className, ...rest } = boxProps;

    const adjustedOpen = over ? !this.state.open : this.state.open;

    return (
      <Box
        width={width}
        className={classes([
          'Dropdown__control',
          'Button',
          'Button--color--' + color,
          disabled && 'Button--disabled',
          className,
        ])}
        onClick={(event) => {
          if (disabled && !this.state.open) {
            return;
          }
          this.setOpen(!this.state.open);
          if (onClick) {
            onClick(event);
          }
        }}
        {...rest}
      >
        {icon && (
          <Icon name={icon} rotation={iconRotation} spin={iconSpin} mr={1} />
        )}
        <span
          className="Dropdown__selected-text"
          style={{
            overflow: clipSelectedText ? 'hidden' : 'visible',
          }}
        >
          {displayText || this.state.selected}
        </span>
        {nochevron || (
          <span className="Dropdown__arrow-button">
            <Icon name={adjustedOpen ? 'chevron-up' : 'chevron-down'} />
          </span>
        )}
      </Box>
    );
  }
}
