/// Get html to load a url.
/// for use inside of browse() calls to html assets that might be loaded on a cdn.
#define URL2HTMLLOADER(url) {"<html><head><meta http-equiv="refresh" content="0;URL='[url]'"/></head><body onLoad="parent.location='[url]'"></body></html>"}

/// Generate a filename for this asset
/// The same asset will always lead to the same asset name
/// Generated names do not include file extension.
#define GENERATE_ASSET_NAME(file) "asset.[md5(fcopy_rsc(file))]"
