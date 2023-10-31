import { classes, pureComponentHooks } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';
import { Component } from 'inferno'
import { Button } from './Button'
import { Icon } from './Icon'

export const Table = (props) => {
  const { className, collapsing, children, ...rest } = props;
  return (
    <table
      className={classes([
        'Table',
        collapsing && 'Table--collapsing',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      <tbody>{children}</tbody>
    </table>
  );
};

Table.defaultHooks = pureComponentHooks;

export const TableRow = (props) => {
  const { className, header, ...rest } = props;
  return (
    <tr
      className={classes([
        'Table__row',
        header && 'Table__row--header',
        className,
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(rest)}
    />
  );
};

TableRow.defaultHooks = pureComponentHooks;

export const TableCell = (props) => {
  const { className, collapsing, header, ...rest } = props;
  return (
    <td
      className={classes([
        'Table__cell',
        collapsing && 'Table__cell--collapsing',
        header && 'Table__cell--header',
        className,
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(rest)}
    />
  );
};

const resolveFunctionalProp = (props, ...data) =>
  props
  ? props instanceof Function
    ? props(...data)
    : props
  : undefined
  ;

class SortableTable extends Component {
  constructor(props) {
    super();
    this.state = {
      sortId: props.sortId ?? props.columns[0].id,
      sortOrder: props.sortOrder ?? 1,
    };
  }

  render() {
    const {
      className,
      columns,
      data,
      datumID,
      filter,
      headerRowProps,
      headerCellProps,
      datumRowProps,
      datumCellProps,
      datumCellChildren,
      ...rest
    } = this.props;
    const {
      sortId,
      sortOrder,
    } = this.state;

    const columnHeaders = columns.map(({ id, name }) => {
      return (
        <Table.Cell key={id}>
          <Button
            color={sortId !== id && 'transparent'}
            width="100%"
            onClick={() => {
              if (sortId === id) {
                this.setState({
                  sortOrder: !sortOrder,
                });
              } else {
                this.setState({
                  sortId: id,
                  sortOrder: true,
                });
              }
            }}
            onDblClick={() =>
              this.setState({
                sortId: null,
              })
            }
            {...headerCellProps?.all}
            {...headerCellProps?.[id]}
          >
            {name}
            {sortId === id && (
              <Icon
                name={sortOrder ? 'sort-up' : 'sort-down'}
                position="absolute"
                right={0}
                top="50%"
                style={{
                  transform: "translate(0, -50%)"
                }}
              />
            )}
          </Button>
        </Table.Cell>
      );
    });
    const dataRows = (filter ? filter(data) : data)
      .sort((a, b) => {
        if (sortId) {
          const i = sortOrder ? 1 : -1;
          return a[sortId].localeCompare(b[sortId]) * i;
        } else {
          return 0;
        }
      })
      .map((datum) => {
        let cells = columns
          .map(({ id, name }) => {
            return (
              <Table.Cell
                key={id}
                {...resolveFunctionalProp(datumCellProps?.all, datum[id]) ?? []}
                {...resolveFunctionalProp(datumCellProps?.[id], datum[id]) ?? []}
              >
                {resolveFunctionalProp(datumCellChildren?.[id], datum[id]) ?? datum[id]}
              </Table.Cell>
            );
          })
          ;

        return (
          <Table.Row
            key={datumID(datum)}
            {...resolveFunctionalProp(datumRowProps, datum) ?? []}
          >
            {cells}
          </Table.Row>
        );
      })
      ;

    return (
      <Table className={classes([ 'SortableTable', className, computeBoxClassName(rest) ])} {...rest}>
        <Table.Row bold {...headerRowProps}>
          {columnHeaders}
        </Table.Row>
        {dataRows}
      </Table>
    );
  }
}

TableCell.defaultHooks = pureComponentHooks;

Table.Row = TableRow;
Table.Cell = TableCell;
Table.Sortable = SortableTable;
