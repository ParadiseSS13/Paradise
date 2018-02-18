export default function runByond(uri) {
  if (process.env.NODE_ENV === 'development') {
    // To prevent browser spam when debugging with `npm run serve`
    return;
  }
  window.location = uri;
}
