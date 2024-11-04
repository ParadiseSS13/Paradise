/**
 * @file
 * @copyright 2024 Aylong (https://github.com/AyIong)
 * @license MIT
 */

import { Placement } from '@popperjs/core';

import { InfernoNode } from 'inferno';
import { BooleanLike, classes } from 'common/react';
import { BoxProps, computeBoxProps } from './Box';
import { Icon } from './Icon';
import { Image } from './Image';
import { DmIcon } from './DmIcon';
import { Stack } from './Stack';
import { Tooltip } from './Tooltip';

type Props = Partial<{
  /** Asset cache. Example: `asset={`assetname32x32, ${thing.key}`}` */
  asset: string[];
  /** Classic way to put images. Example: `base64={thing.image}` */
  base64: string;
  /**
   * Special container for buttons.
   * You can put any other component here.
   * Has some special stylings!
   * Example: `buttons={<Button>Send</Button>}`
   */
  buttons: InfernoNode;
  /** Enables alternate buttons container. Disables pointer-events on buttons if non-fluid. */
  buttonsAlt: boolean;
  /** Content under image. Or on the right if fluid. */
  children: InfernoNode;
  /** Applies a CSS class to the element. */
  className: string;
  /** Color of the button. See [Button](#button) but without `transparent`. */
  color: string;
  /** Makes button disabled and dark red if true. Also disables onClick. */
  disabled: BooleanLike;
  /** Optional. Adds a "stub" when loading DmIcon. */
  dmFallback: InfernoNode;
  /** Parameter `icon` of component `DmIcon`. */
  dmIcon: string | null;
  /** Parameter `icon_state` of component `DmIcon`. */
  dmIconState: string | null;
  /**
   * Changes the layout of the button, making it fill the entire horizontally available space.
   * Allows the use of `title`
   */
  fluid: boolean;
  /** Parameter responsible for the size of the image, component and standard "stubs". */
  imageSize: number;
  /** Prop `src` of <img>. Example: `imageSrc={resolveAsset(thing.image}` */
  imageSrc: string;
  /** Called when button is clicked with LMB. */
  onClick: (e: any) => void;
  /** Called when button is clicked with RMB. */
  onRightClick: (e: any) => void;
  /** Makes button selected and green if true. */
  selected: BooleanLike;
  /** Requires `fluid` for work. Bold text with divider betwen content. */
  title: string;
  /** A fancy, boxy tooltip, which appears when hovering over the button */
  tooltip: InfernoNode;
  /** Position of the tooltip. See [`Popper`](#Popper) for valid options. */
  tooltipPosition: Placement;
}> &
  BoxProps;

export const ImageButton = (props: Props) => {
  const {
    asset,
    base64,
    buttons,
    buttonsAlt,
    children,
    className,
    color,
    disabled,
    dmFallback,
    dmIcon,
    dmIconState,
    fluid,
    imageSize = 64,
    imageSrc,
    onClick,
    onRightClick,
    selected,
    title,
    tooltip,
    tooltipPosition,
    ...rest
  } = props;

  const getFallback = (iconName: string, iconSpin: boolean) => {
    return (
      <Stack height={`${imageSize}px`} width={`${imageSize}px`}>
        <Stack.Item grow textAlign="center" align="center">
          <Icon spin={iconSpin} name={iconName} color="gray" style={{ 'font-size': `calc(${imageSize}px * 0.75)` }} />
        </Stack.Item>
      </Stack>
    );
  };

  let buttonContent = (
    <div
      className={classes([
        'container',
        buttons && 'hasButtons',
        !onClick && !onRightClick && 'noAction',
        selected && 'selected',
        disabled && 'disabled',
        color && typeof color === 'string' ? 'color__' + color : 'color__default',
      ])}
      tabIndex={!disabled ? 0 : undefined}
      onClick={(event) => {
        if (!disabled && onClick) {
          onClick(event);
        }
      }}
      onContextMenu={(event) => {
        event.preventDefault();
        if (!disabled && onRightClick) {
          onRightClick(event);
        }
      }}
      style={{ width: !fluid ? `calc(${imageSize}px + 0.5em + 2px)` : 'auto' }}
    >
      <div className={classes(['image'])}>
        {base64 || asset || imageSrc ? (
          <Image
            className={classes((!base64 && !imageSrc && asset) || [])}
            src={base64 ? `data:image/jpeg;base64,${base64}` : imageSrc}
            height={`${imageSize}px`}
            width={`${imageSize}px`}
          />
        ) : dmIcon && dmIconState ? (
          <DmIcon
            icon={dmIcon}
            icon_state={dmIconState}
            fallback={dmFallback ? dmFallback : getFallback('spinner', true)}
            height={`${imageSize}px`}
            width={`${imageSize}px`}
          />
        ) : (
          getFallback('question', false)
        )}
      </div>
      {fluid ? (
        <div className={classes(['info'])}>
          {title && <span className={classes(['title', children && 'divider'])}>{title}</span>}
          {children && <span className={classes(['contentFluid'])}>{children}</span>}
        </div>
      ) : (
        children && (
          <span
            className={classes([
              'content',
              selected && 'contentSelected',
              disabled && 'contentDisabled',
              color && typeof color === 'string' ? 'contentColor__' + color : 'contentColor__default',
            ])}
          >
            {children}
          </span>
        )
      )}
    </div>
  );

  if (tooltip) {
    buttonContent = (
      <Tooltip content={tooltip} position={tooltipPosition as Placement}>
        {buttonContent}
      </Tooltip>
    );
  }

  return (
    <div className={classes(['ImageButton', fluid && 'fluid', className])} {...computeBoxProps(rest)}>
      {buttonContent}
      {buttons && (
        <div
          className={classes([
            'buttonsContainer',
            buttonsAlt && 'buttonsAltContainer',
            !children && 'buttonsEmpty',
            fluid && color && typeof color === 'string'
              ? 'buttonsContainerColor__' + color
              : fluid && 'buttonsContainerColor__default',
          ])}
          style={{
            width: buttonsAlt ? `calc(${imageSize}px + ${fluid ? 0 : 0.5}em)` : 'auto',
            'max-width': !fluid && !buttonsAlt && `calc(${imageSize}px +  0.5em)`,
          }}
        >
          {buttons}
        </div>
      )}
    </div>
  );
};
