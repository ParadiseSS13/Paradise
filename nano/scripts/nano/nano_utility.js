// NanoUtility is the place to store utility functions
var NanoUtility = function () {
    var _urlParameters = {}; // This is populated with the base url parameters (used by all links), which is probaby just the "src" parameter

    return {
        init: function () {
            var body = $('body'); // We store data in the body tag, it's as good a place as any
            _urlParameters = body.data('urlParameters');
        },
        // generate a Byond href, combines _urlParameters with parameters
        generateHref: function (parameters) {
            var queryString = '?';

            for (var key in _urlParameters) {
                if (_urlParameters.hasOwnProperty(key)) {
                    if (queryString !== '?') {
                        queryString += ';';
                    }
                    queryString += key + '=' + _urlParameters[key];
                }
            }

            for (var key in parameters)
            {
                if (parameters.hasOwnProperty(key)) {
                    if (queryString !== '?') {
                        queryString += ';';
                    }
                    queryString += key + '=' + parameters[key];
                }
            }
            return queryString;
        },
        winset: function (key, value, window) {
            var obj, params, winsetRef;
            if (window == null) {
                window = NanoStateManager.getData().config.window.ref;
            }
            params = (
                obj = {},
                obj[window + "." + key] = value,
                obj
            );
            return location.href = NanoUtility.href("winset", params);
        },
        extend: function(first, second) {
            Object.keys(second).forEach(function(key) {
                var secondVal;
                secondVal = second[key];
                if (secondVal && Object.prototype.toString.call(secondVal) === "[object Object]") {
                    first[key] = first[key] || {};
                    return NanoUtility.extend(first[key], secondVal);
                } else {
                    return first[key] = secondVal;
                }
            });
            return first;
        },
        href: function(url, params) {
            if (url == null) {
                url = "";
            }
            if (params == null) {
                params = {};
            }
            url = new Url("byond://" + url);
            NanoUtility.extend(url.query, params);
            return url;
        },
        close: function() {
            var params;
            params = {
                command: "nanoclose " + _urlParameters.src
            };
            this.winset("is-visible", "false");
            return location.href = NanoUtility.href("winset", params);
        }
    }
} ();

if (typeof jQuery == 'undefined') {  
    reportError('ERROR: Javascript library failed to load!');
}
if (typeof doT == 'undefined') {  
    reportError('ERROR: Template engine failed to load!');
}

var reportError = function (str) {
    window.location = "byond://?nano_err=" + encodeURIComponent(str);
    alert(str);
}

// All scripts are initialised here, this allows control of init order
$(document).ready(function () {
    NanoUtility.init();
    NanoStateManager.init();
    NanoTemplate.init();
    NanoWindow.init();
});

if (!Array.prototype.indexOf)
{
    Array.prototype.indexOf = function(elt /*, from*/)
    {
        var len = this.length;

        var from = Number(arguments[1]) || 0;
        from = (from < 0)
            ? Math.ceil(from)
            : Math.floor(from);
        if (from < 0)
            from += len;

        for (; from < len; from++)
        {
            if (from in this &&
                this[from] === elt)
                return from;
        }
        return -1;
    };
};

if (!String.prototype.format)
{
    String.prototype.format = function (args) {
        var str = this;
        return str.replace(String.prototype.format.regex, function(item) {
            var intVal = parseInt(item.substring(1, item.length - 1));
            var replace;
            if (intVal >= 0) {
                replace = args[intVal];
            } else if (intVal === -1) {
                replace = "{";
            } else if (intVal === -2) {
                replace = "}";
            } else {
                replace = "";
            }
            return replace;
        });
    };
    String.prototype.format.regex = new RegExp("{-?[0-9]+}", "g");
};

Object.size = function(obj) {
    var size = 0, key;
    for (var key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

if(!window.console) {
    window.console = {
        log : function(str) {
            return false;
        }
    };
};

String.prototype.toTitleCase = function () {
    var smallWords = /^(a|an|and|as|at|but|by|en|for|if|in|of|on|or|the|to|vs?\.?|via)$/i;

    return this.replace(/([^\W_]+[^\s-]*) */g, function (match, p1, index, title) {
        if (index > 0 && index + p1.length !== title.length &&
            p1.search(smallWords) > -1 && title.charAt(index - 2) !== ":" &&
            title.charAt(index - 1).search(/[^\s-]/) < 0) {
            return match.toLowerCase();
        }

        if (p1.substr(1).search(/[A-Z]|\../) > -1) {
            return match;
        }

        return match.charAt(0).toUpperCase() + match.substr(1);
    });
};

$.ajaxSetup({
    cache: false
});

Function.prototype.inheritsFrom = function (parentClassOrObject) {
    this.prototype = new parentClassOrObject;
    this.prototype.constructor = this;
    this.prototype.parent = parentClassOrObject.prototype;
    return this;
};

if (!String.prototype.trim) {
    String.prototype.trim = function () {
        return this.replace(/^\s+|\s+$/g, '');
    };
}

// Replicate the ckey proc from BYOND
if (!String.prototype.ckey) {
    String.prototype.ckey = function () {
        return this.replace(/\W/g, '').toLowerCase();
    };
}