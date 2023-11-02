import { Component } from 'inferno';
import { Flex, Input, Section, Table } from '../../components';
import { FlexItem } from '../../components/Flex';
import { createSearch } from 'common/string';
import { classes } from 'common/react';

export class RecordsTable extends Component {
  constructor() {
    super();
    this.state = {
      searchText: '',
    };
  }

  render() {
    const {
      className,
      columns,
      leftButtons,
      rightButtons,
      searchPlaceholder,
      ...rest
    } = this.props;
    const { searchText } = this.state;
    return (
      <Flex direction="column" height="100%">
        <Flex className="RecordsTable_Toolbar">
          {leftButtons}
          <FlexItem grow="1">
            <Input
              placeholder={searchPlaceholder}
              width="100%"
              onInput={(e, value) => this.setState({ searchText: value })}
            />
          </FlexItem>
          {rightButtons}
        </Flex>
        <Section flexGrow="1" mt="0.5rem">
          <Table.Sortable
            className={classes(['RecordsTable', className])}
            columns={columns}
            filter={(data) =>
              data.filter(
                createSearch(searchText, (datum) =>
                  columns.map((c) => datum[c.id]).join('|')
                )
              )
            }
            {...rest}
          />
        </Section>
      </Flex>
    );
  }
}
