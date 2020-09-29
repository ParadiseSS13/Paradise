import { useBackend, useLocalState } from "../../backend";
import { Input } from "../../components";

export const LatheSearch = (properties, context) => {
  const { act } = useBackend(context);

  const [inputValue, setInputValue] = useLocalState(context, 'inputValue', '');

  const onSubmit = e => {
    e.preventDefault();
    act('search', { to_search: inputValue });
  };

  return (
    <form onSubmit={onSubmit}>
      <Input
        onInput={(e, value) => setInputValue(value)} />
      <button type="submit">Search</button>
    </form>
  );
};
