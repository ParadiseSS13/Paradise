import { backendUpdate, setGlobalStore } from 'tgui/backend';
import { DisposalBin } from 'tgui/interfaces/DisposalBin';
import { render } from 'tgui/renderer';
import { configureStore } from 'tgui/store';

const store = configureStore({ sideEffects: false });

export const data = JSON.stringify({
  is_ai: 0,
  flushing: 0,
  mode: 1,
  pressure: 1,
});

export function Default() {
  setGlobalStore(store);

  store.dispatch(
    backendUpdate({
      data: Byond.parseJson(data),
    })
  );

  return render(<DisposalBin />);
}
