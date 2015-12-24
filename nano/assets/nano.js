// NanoUtility is the place to store utility functions
var NanoUtility = function () 
{
    var _urlParameters = {}; // This is populated with the base url parameters (used by all links), which is probaby just the "src" parameter

	return {
        init: function () 
		{
			var body = $('body'); // We store data in the body tag, it's as good a place as any

			_urlParameters = body.data('urlParameters');
        },
		// generate a Byond href, combines _urlParameters with parameters
		generateHref: function (parameters)
		{
			var queryString = '?';

			for (var key in _urlParameters)
			{
				if (_urlParameters.hasOwnProperty(key))
				{
					if (queryString !== '?')
					{
						queryString += ';';
					}
					queryString += key + '=' + _urlParameters[key];
				}
			}

			for (var key in parameters)
			{
				if (parameters.hasOwnProperty(key))
				{
					if (queryString !== '?')
					{
						queryString += ';';
					}
					queryString += key + '=' + parameters[key];
				}
			}
			return queryString;
		}
    }
} (); 

if (typeof jQuery == 'undefined') {  
	alert('ERROR: Javascript library failed to load!');
}
if (typeof doT == 'undefined') {  
	alert('ERROR: Template engine failed to load!');
}	

(function() {
	var _alert = window.alert;
	window.alert = function(str) {
		window.location = "byond://?nano_err=" + encodeURIComponent(str);
		_alert(str);
	};
})();

// All scripts are initialised here, this allows control of init order
$(document).ready(function () {
	NanoUtility.init();
	NanoStateManager.init();
	NanoTemplate.init();
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

var NanoTemplate = function () {

    var _templateData = {};

    var _templates = {};
    var _compiledTemplates = {};
	
	var _helpers = {};

    var init = function () {
        // We store templateData in the body tag, it's as good a place as any
		_templateData = $('body').data('templateData');

		if (_templateData == null)
		{
			alert('Error: Template data did not load correctly.');
		}

		loadNextTemplate();
    };

    var loadNextTemplate = function () {
        // we count the number of templates for this ui so that we know when they've all been rendered
        var templateCount = Object.size(_templateData);

        if (!templateCount)
        {
            $(document).trigger('templatesLoaded');
            return;
        }

        // load markup for each template and register it
        for (var key in _templateData)
        {
            if (!_templateData.hasOwnProperty(key))
            {
                continue;
            }

            $.when($.ajax({
                    url: _templateData[key],
                    cache: false,
                    dataType: 'text'
                }))
                .done(function(templateMarkup) {

                    templateMarkup += '<div class="clearBoth"></div>';

                    try
                    {
                        NanoTemplate.addTemplate(key, templateMarkup);
                    }
                    catch(error)
                    {
                        alert('ERROR: An error occurred while loading the UI: ' + error.message);
                        return;
                    }

                    delete _templateData[key];

                    loadNextTemplate();
                })
                .fail(function () {
                    alert('ERROR: Loading template ' + key + '(' + _templateData[key] + ') failed!');
                });

            return;
        }
    }

    var compileTemplates = function () {

        for (var key in _templates) {
            try {
                _compiledTemplates[key] = doT.template(_templates[key], null, _templates)
            }
            catch (error) {
                alert(error.message);
            }
        }
    };

    return {
        init: function () {
            init();
        },
        addTemplate: function (key, templateString) {
            _templates[key] = templateString;
        },
        templateExists: function (key) {
            return _templates.hasOwnProperty(key);
        },
        parse: function (templateKey, data) {
            if (!_compiledTemplates.hasOwnProperty(templateKey) || !_compiledTemplates[templateKey]) {
                if (!_templates.hasOwnProperty(templateKey)) {
                    alert('ERROR: Template "' + templateKey + '" does not exist in _compiledTemplates!');
                    return '<h2>Template error (does not exist)</h2>';
                }
                compileTemplates();
            }
            if (typeof _compiledTemplates[templateKey] != 'function') {
                alert(_compiledTemplates[templateKey]);
                alert('ERROR: Template "' + templateKey + '" failed to compile!');
                return '<h2>Template error (failed to compile)</h2>';
            }
            return _compiledTemplates[templateKey].call(this, data['data'], data['config'], _helpers);
        },
		addHelper: function (helperName, helperFunction) {
			if (!jQuery.isFunction(helperFunction)) {
				alert('NanoTemplate.addHelper failed to add ' + helperName + ' as it is not a function.');
				return;	
			}
			
			_helpers[helperName] = helperFunction;
		},
		addHelpers: function (helpers) {		
			for (var helperName in helpers) {
				if (!helpers.hasOwnProperty(helperName))
				{
					continue;
				}
				NanoTemplate.addHelper(helperName, helpers[helperName]);
			}
		},
		removeHelper: function (helperName) {
			if (helpers.hasOwnProperty(helperName))
			{
				delete _helpers[helperName];
			}	
		}
    }
}();
 


// NanoStateManager handles data from the server and uses it to render templates
NanoStateManager = function () 
{
	// _isInitialised is set to true when all of this ui's templates have been processed/rendered
	var _isInitialised = false;

	// the data for this ui
	var _data = null;
	
	// this is an array of callbacks which are called when new data arrives, before it is processed
	var _beforeUpdateCallbacks = {};
	// this is an array of callbacks which are called when new data arrives, before it is processed
	var _afterUpdateCallbacks = {};		
	
	// this is an array of state objects, these can be used to provide custom javascript logic
	var _states = {};	
	
	var _currentState = null;
	
	// the init function is called when the ui has loaded
	// this function sets up the templates and base functionality
	var init = function () 
	{
		// We store initialData and templateData in the body tag, it's as good a place as any
		_data = $('body').data('initialData');	
		
		if (_data == null || !_data.hasOwnProperty('config') || !_data.hasOwnProperty('data'))
		{
			alert('Error: Initial data did not load correctly.');
		}

		var stateKey = 'default';
		if (_data['config'].hasOwnProperty('stateKey') && _data['config']['stateKey'])
		{
			stateKey = _data['config']['stateKey'].toLowerCase();
		}

		NanoStateManager.setCurrentState(stateKey);
		
		$(document).on('templatesLoaded', function () {
			doUpdate(_data);
			
			_isInitialised = true;
		});
	};
	
	// Receive update data from the server
	var receiveUpdateData = function (jsonString)
	{
		var updateData;
		
		// alert("recieveUpdateData called." + "<br>Type: " + typeof jsonString); //debug hook
		try
		{
			// parse the JSON string from the server into a JSON object
			updateData = jQuery.parseJSON(jsonString);
		}
		catch (error)
		{
			alert("recieveUpdateData failed. " + "<br>Error name: " + error.name + "<br>Error Message: " + error.message);
			return;
		}

		// alert("recieveUpdateData passed trycatch block."); //debug hook
		
		if (!updateData.hasOwnProperty('data'))
		{
			if (_data && _data.hasOwnProperty('data'))
			{
				updateData['data'] = _data['data'];
			}
			else
			{
				updateData['data'] = {};
			}
		}
		
		if (_isInitialised) // all templates have been registered, so render them
		{
			doUpdate(updateData);
		}
		else
		{
			_data = updateData; // all templates have not been registered. We set _data directly here which will be applied after the template is loaded with the initial data
		}	
	};

	// This function does the update by calling the methods on the current state
	var doUpdate = function (data)
	{
        if (_currentState == null)
        {
            return;
        }

		data = _currentState.onBeforeUpdate(data);

		if (data === false)
		{
            alert('data is false, return');
			return; // A beforeUpdateCallback returned a false value, this prevents the render from occuring
		}
		
		_data = data;

        _currentState.onUpdate(_data);

        _currentState.onAfterUpdate(_data);
	};
	
	// Execute all callbacks in the callbacks array/object provided, updateData is passed to them for processing and potential modification
	var executeCallbacks = function (callbacks, data)
	{	
		for (var key in callbacks)
		{
			if (callbacks.hasOwnProperty(key) && jQuery.isFunction(callbacks[key]))
			{
                data = callbacks[key].call(this, data);
			}
		}
		
		return data;
	};

	return {
        init: function () 
		{
            init();
        },
		receiveUpdateData: function (jsonString) 
		{
			receiveUpdateData(jsonString);
        },
		addBeforeUpdateCallback: function (key, callbackFunction)
		{
			_beforeUpdateCallbacks[key] = callbackFunction;
		},
		addBeforeUpdateCallbacks: function (callbacks) {		
			for (var callbackKey in callbacks) {
				if (!callbacks.hasOwnProperty(callbackKey))
				{
					continue;
				}
				NanoStateManager.addBeforeUpdateCallback(callbackKey, callbacks[callbackKey]);
			}
		},
		removeBeforeUpdateCallback: function (key)
		{
			if (_beforeUpdateCallbacks.hasOwnProperty(key))
			{
				delete _beforeUpdateCallbacks[key];
			}
		},
        executeBeforeUpdateCallbacks: function (data) {
            return executeCallbacks(_beforeUpdateCallbacks, data);
        },
		addAfterUpdateCallback: function (key, callbackFunction)
		{
			_afterUpdateCallbacks[key] = callbackFunction;
		},
		addAfterUpdateCallbacks: function (callbacks) {		
			for (var callbackKey in callbacks) {
				if (!callbacks.hasOwnProperty(callbackKey))
				{
					continue;
				}
				NanoStateManager.addAfterUpdateCallback(callbackKey, callbacks[callbackKey]);
			}
		},
		removeAfterUpdateCallback: function (key)
		{
			if (_afterUpdateCallbacks.hasOwnProperty(key))
			{
				delete _afterUpdateCallbacks[key];
			}
		},
        executeAfterUpdateCallbacks: function (data) {
            return executeCallbacks(_afterUpdateCallbacks, data);
        },
		addState: function (state)
		{
			if (!(state instanceof NanoStateClass))
			{
				alert('ERROR: Attempted to add a state which is not instanceof NanoStateClass');
				return;
			}
			if (!state.key)
			{
				alert('ERROR: Attempted to add a state with an invalid stateKey');
				return;
			}
			_states[state.key] = state;
		},
		setCurrentState: function (stateKey)
		{
			if (typeof stateKey == 'undefined' || !stateKey) {
				alert('ERROR: No state key was passed!');				
                return false;
            }
			if (!_states.hasOwnProperty(stateKey))
			{
				alert('ERROR: Attempted to set a current state which does not exist: ' + stateKey);
				return false;
			}			
			
			var previousState = _currentState;
			
            _currentState = _states[stateKey];

            if (previousState != null) {
                previousState.onRemove(_currentState);
            }            
			
			_currentState.onAdd(previousState);

            return true;
		},
		getCurrentState: function ()
		{
			return _currentState;
		}
	};
} ();
 
// This is the base state class, it is not to be used directly

function NanoStateClass() {
	/*if (typeof this.key != 'string' || !this.key.length)
	{
		alert('ERROR: Tried to create a state with an invalid state key: ' + this.key);
		return;
	}
	
    this.key = this.key.toLowerCase();
	
	NanoStateManager.addState(this);*/
}

NanoStateClass.prototype.key = null;
NanoStateClass.prototype.layoutRendered = false;
NanoStateClass.prototype.contentRendered = false;
NanoStateClass.prototype.mapInitialised = false;

NanoStateClass.prototype.isCurrent = function () {
    return NanoStateManager.getCurrentState() == this;
};

NanoStateClass.prototype.onAdd = function (previousState) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    NanoBaseCallbacks.addCallbacks();
    NanoBaseHelpers.addHelpers();
};

NanoStateClass.prototype.onRemove = function (nextState) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    NanoBaseCallbacks.removeCallbacks();
    NanoBaseHelpers.removeHelpers();
};

NanoStateClass.prototype.onBeforeUpdate = function (data) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    data = NanoStateManager.executeBeforeUpdateCallbacks(data);

    return data; // Return data to continue, return false to prevent onUpdate and onAfterUpdate
};

NanoStateClass.prototype.onUpdate = function (data) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    try
    {
        if (!this.layoutRendered || (data['config'].hasOwnProperty('autoUpdateLayout') && data['config']['autoUpdateLayout']))
        {
            $("#uiLayout").html(NanoTemplate.parse('layout', data)); // render the 'mail' template to the #mainTemplate div
            this.layoutRendered = true;
        }
        if (!this.contentRendered || (data['config'].hasOwnProperty('autoUpdateContent') && data['config']['autoUpdateContent']))
        {
            $("#uiContent").html(NanoTemplate.parse('main', data)); // render the 'mail' template to the #mainTemplate div
            this.contentRendered = true;
        }
        if (NanoTemplate.templateExists('mapContent'))
        {
            if (!this.mapInitialised)
            {
                // Add drag functionality to the map ui
                $('#uiMap').draggable();

                $('#uiMapTooltip')
                    .off('click')
                    .on('click', function (event) {
                        event.preventDefault();
                        $(this).fadeOut(400);
                    });

                this.mapInitialised = true;
            }

            $("#uiMapContent").html(NanoTemplate.parse('mapContent', data)); // render the 'mapContent' template to the #uiMapContent div

            if (data['config'].hasOwnProperty('showMap') && data['config']['showMap'])
            {
                $('#uiContent').addClass('hidden');
                $('#uiMapWrapper').removeClass('hidden');
            }
            else
            {
                $('#uiMapWrapper').addClass('hidden');
                $('#uiContent').removeClass('hidden');
            }
        }
        if (NanoTemplate.templateExists('mapHeader'))
        {
            $("#uiMapHeader").html(NanoTemplate.parse('mapHeader', data)); // render the 'mapHeader' template to the #uiMapHeader div
        }
        if (NanoTemplate.templateExists('mapFooter'))
        {
            $("#uiMapFooter").html(NanoTemplate.parse('mapFooter', data)); // render the 'mapFooter' template to the #uiMapFooter div
        }
    }
    catch(error)
    {
        alert('ERROR: An error occurred while rendering the UI: ' + error.message);
        return;
    }
};

NanoStateClass.prototype.onAfterUpdate = function (data) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    NanoStateManager.executeAfterUpdateCallbacks(data);
};

NanoStateClass.prototype.alertText = function (text) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    alert(text);
};




NanoStateDefaultClass.inheritsFrom(NanoStateClass);
var NanoStateDefault = new NanoStateDefaultClass();

function NanoStateDefaultClass() {

    this.key = 'default';

    //this.parent.constructor.call(this);

    this.key = this.key.toLowerCase();

    NanoStateManager.addState(this);
}
// NanoBaseCallbacks is where the base callbacks (common to all templates) are stored
NanoBaseCallbacks = function ()
{
	// _canClick is used to disable clicks for a short period after each click (to avoid mis-clicks)
	var _canClick = true;
	
	var _baseBeforeUpdateCallbacks = {}
	
	var _baseAfterUpdateCallbacks = {
		// this callback is triggered after new data is processed
		// it updates the status/visibility icon and adds click event handling to buttons/links		
		status: function (updateData) {
			var uiStatusClass;
			if (updateData['config']['status'] == 2)
			{
				uiStatusClass = 'icon24 uiStatusGood';
				$('.linkActive').removeClass('inactive');
			}
			else if (updateData['config']['status'] == 1)
			{
				uiStatusClass = 'icon24 uiStatusAverage';
				$('.linkActive').addClass('inactive');
			}
			else
			{
				uiStatusClass = 'icon24 uiStatusBad'
				$('.linkActive').addClass('inactive');
			}
			$('#uiStatusIcon').attr('class', uiStatusClass);

			$('.linkActive').stopTime('linkPending');
			$('.linkActive').removeClass('linkPending');

			$('.linkActive')
                .off('click')
			    .on('click', function (event) {
                    event.preventDefault();
                    var href = $(this).data('href');
                    if (href != null && _canClick)
                    {
                        _canClick = false;
                        $('body').oneTime(300, 'enableClick', function () {
                            _canClick = true;
                        });
                        if (updateData['config']['status'] == 2)
                        {
                            $(this).oneTime(300, 'linkPending', function () {
                                $(this).addClass('linkPending');
                            });
                        }
                        window.location.href = href;
                    }
                });

            return updateData;
		},
        nanomap: function (updateData) {
            $('.mapIcon')
                .off('mouseenter mouseleave')
                .on('mouseenter',
                    function (event) {
                        var self = this;
                        $('#uiMapTooltip')
                            .html($(this).children('.tooltip').html())
                            .show()
                            .stopTime()
                            .oneTime(5000, 'hideTooltip', function () {
                                $(this).fadeOut(500);
                            });
                    }
                );

            $('.zoomLink')
                .off('click')
                .on('click', function (event) {
                    event.preventDefault();
                    var zoomLevel = $(this).data('zoomLevel');
                    var uiMapObject = $('#uiMap');
                    var uiMapWidth = uiMapObject.width() * zoomLevel;
                    var uiMapHeight = uiMapObject.height() * zoomLevel;

                    uiMapObject.css({
                        zoom: zoomLevel,
                        left: '50%',
                        top: '50%',
                        marginLeft: '-' + Math.floor(uiMapWidth / 2) + 'px',
                        marginTop: '-' + Math.floor(uiMapHeight / 2) + 'px'
                    });
                });

            $('#uiMapImage').attr('src', 'nanomap_z' + updateData['config']['mapZLevel'] + '.png');

            return updateData;
        }
	};

	return {
		addCallbacks: function () {
			NanoStateManager.addBeforeUpdateCallbacks(_baseBeforeUpdateCallbacks);
			NanoStateManager.addAfterUpdateCallbacks(_baseAfterUpdateCallbacks);
		},
		removeCallbacks: function () {
			for (var callbackKey in _baseBeforeUpdateCallbacks)
			{
				if (_baseBeforeUpdateCallbacks.hasOwnProperty(callbackKey))
				{
					NanoStateManager.removeBeforeUpdateCallback(callbackKey);
				}
			}
            for (var callbackKey in _baseAfterUpdateCallbacks)
            {
                if (_baseAfterUpdateCallbacks.hasOwnProperty(callbackKey))
                {
                    NanoStateManager.removeAfterUpdateCallback(callbackKey);
                }
            }
        }
	};
} ();
 







// NanoBaseHelpers is where the base template helpers (common to all templates) are stored
NanoBaseHelpers = function ()
{
	var _baseHelpers = {
            // change ui styling to "syndicate mode"
			syndicateMode: function() {
				$('body').css("background-color","#8f1414");
				$('body').css("background-image","url('uiBackground-Syndicate.png')");
				$('body').css("background-position","50% 0");
				$('body').css("background-repeat","repeat-x");

				$('#uiTitleFluff').css("background-image","url('uiTitleFluff-Syndicate.png')");
				$('#uiTitleFluff').css("background-position","50% 50%");
				$('#uiTitleFluff').css("background-repeat", "no-repeat");

				return '';
			},
            combine: function( arr1, arr2 ) {
                return arr1 && arr2 ? arr1.concat(arr2) : arr1 || arr2;
            },  
            dump: function( arr1 ) {
                return JSON.stringify(arr1);
            },
			// Generate a Byond link
			link: function( text, icon, parameters, status, elementClass, elementId) {

				var iconHtml = '';
				var iconClass = 'noIcon';
				if (typeof icon != 'undefined' && icon)
				{
					iconHtml = '<div class="uiLinkPendingIcon"></div><div class="uiIcon16 icon-' + icon + '"></div>';
					iconClass = 'hasIcon';
				}

				if (typeof elementClass == 'undefined' || !elementClass)
				{
					elementClass = 'link';
				}

				var elementIdHtml = '';
				if (typeof elementId != 'undefined' && elementId)
				{
					elementIdHtml = 'id="' + elementId + '"';
				}

				if (typeof status != 'undefined' && status)
				{
					return '<div unselectable="on" class="link ' + iconClass + ' ' + elementClass + ' ' + status + '" ' + elementIdHtml + '>' + iconHtml + text + '</div>';
				}

				return '<div unselectable="on" class="linkActive ' + iconClass + ' ' + elementClass + '" data-href="' + NanoUtility.generateHref(parameters) + '" ' + elementIdHtml + '>' + iconHtml + text + '</div>';
			},
			// Since jsrender breaks the ^ operator
            xor: function(number,bit) {                               
                return number ^ bit;
            },
            precisionRound: function (value, places) {
                if(places==0)
                    return Math.round(number);
                var multiplier = Math.pow(10, places);
                return (Math.round(value * multiplier) / multiplier);
            },
			// Round a number to the nearest integer
			round: function(number) {
				return Math.round(number);
			},
			fixed: function(number) {
				return Math.round(number * 10) / 10;
			},
			// Round a number down to integer
			floor: function(number) {
				return Math.floor(number);
			},
			// Round a number up to integer
			ceil: function(number) {
				return Math.ceil(number);
			},
			// Format a string (~string("Hello {0}, how are {1}?", 'Martin', 'you') becomes "Hello Martin, how are you?")
			string: function() {
				if (arguments.length == 0)
				{
					return '';
				}
				else if (arguments.length == 1)
				{
					return arguments[0];
				}
				else if (arguments.length > 1)
				{
					stringArgs = [];
					for (var i = 1; i < arguments.length; i++)
					{
						stringArgs.push(arguments[i]);
					}
					return arguments[0].format(stringArgs);
				}
				return '';
			},
			formatNumber: function(x) {
				// From http://stackoverflow.com/questions/2901102/how-to-print-a-number-with-commas-as-thousands-separators-in-javascript
				var parts = x.toString().split(".");
				parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
				return parts.join(".");
			},
			// Capitalize the first letter of a string. From http://stackoverflow.com/questions/1026069/capitalize-the-first-letter-of-string-in-javascript
			capitalizeFirstLetter: function(string) {
				return string.charAt(0).toUpperCase() + string.slice(1);
			},
			// Display a bar. Used to show health, capacity, etc.
			displayBar: function(value, rangeMin, rangeMax, styleClass, showText) {

				if (rangeMin < rangeMax)
                {
                    if (value < rangeMin)
                    {
                        value = rangeMin;
                    }
                    else if (value > rangeMax)
                    {
                        value = rangeMax;
                    }
                }
                else
                {
                    if (value > rangeMin)
                    {
                        value = rangeMin;
                    }
                    else if (value < rangeMax)
                    {
                        value = rangeMax;
                    }
                }

				if (typeof styleClass == 'undefined' || !styleClass)
				{
					styleClass = '';
				}

				if (typeof showText == 'undefined' || !showText)
				{
					showText = '';
				}

				var percentage = Math.round((value - rangeMin) / (rangeMax - rangeMin) * 100);

				return '<div class="displayBar ' + styleClass + '"><div class="displayBarFill ' + styleClass + '" style="width: ' + percentage + '%;"></div><div class="displayBarText ' + styleClass + '">' + showText + '</div></div>';
			},
			// Convert danger level to class (for the air alarm)
			dangerToClass: function(level) {
				if(level==0) return 'good';
				if(level==1) return 'average';
				return 'bad';
			},
			dangerToSpan: function(level) {
				if(level==0) return '"<span class="good">Good</span>"';
				if(level==1) return '"<span class="average">Minor Alert</span>"';
				return '"<span class="bad">Major Alert</span>"';
			},
			generateHref: function (parameters) {
				var body = $('body'); // We store data in the body tag, it's as good a place as any
				_urlParameters = body.data('urlParameters');
				var queryString = '?';
	
				for (var key in _urlParameters)
				{
					if (_urlParameters.hasOwnProperty(key))
					{
						if (queryString !== '?')
						{
							queryString += ';';
						}
						queryString += key + '=' + _urlParameters[key];
					}
				}

				for (var key in parameters)
				{
					if (parameters.hasOwnProperty(key))
					{
						if (queryString !== '?')
						{
							queryString += ';';
						}
						queryString += key + '=' + parameters[key];
					}
				}
				return queryString;
			},
			// Display DNA Blocks (for the DNA Modifier UI)
			displayDNABlocks: function(dnaString, selectedBlock, selectedSubblock, blockSize, paramKey) {
			    if (!dnaString)
				{
					return '<div class="notice">Please place a valid subject into the DNA modifier.</div>';
				}

				var characters = dnaString.split('');

                var html = '<div class="dnaBlock"><div class="link dnaBlockNumber">1</div>';
                var block = 1;
                var subblock = 1;
                for (index in characters)
                {
					if (!characters.hasOwnProperty(index) || typeof characters[index] === 'object')
					{
						continue;
					}

					var parameters;
					if (paramKey.toUpperCase() == 'UI')
					{
						parameters = { 'selectUIBlock' : block, 'selectUISubblock' : subblock };
					}
					else
					{
						parameters = { 'selectSEBlock' : block, 'selectSESubblock' : subblock };
					}

                    var status = 'linkActive';
                    if (block == selectedBlock && subblock == selectedSubblock)
                    {
                        status = 'selected';
                    }

                    html += '<div class="link ' + status + ' dnaSubBlock" data-href="' + NanoUtility.generateHref(parameters) + '" id="dnaBlock' + index + '">' + characters[index] + '</div>'

                    index++;
                    if (index % blockSize == 0 && index < characters.length)
                    {
						block++;
                        subblock = 1;
                        html += '</div><div class="dnaBlock"><div class="link dnaBlockNumber">' + block + '</div>';
                    }
                    else
                    {
                        subblock++;
                    }
                }

                html += '</div>';

				return html;
			},
			cMirror: function(domID) {
				if(!domID)
				{
				    return "ERR - NO domID provided";
				}
				
			    var html = '<script>var editor = CodeMirror.fromTextArea(document.getElementById("';
			    html += domID
				html += '"), {lineNumbers: true,	indentUnit: 4,	indentWithTabs: true,	theme: "lesser-dark"});';
			    html += '</script>'
				return html;
			}
		};
		
	return {
        addHelpers: function ()
		{
            NanoTemplate.addHelpers(_baseHelpers);
        },
		removeHelpers: function ()
		{
			for (var helperKey in _baseHelpers)
			{
				if (_baseHelpers.hasOwnProperty(helperKey))
				{
					NanoTemplate.removeHelper(helperKey);
				}
			}            
        }
	};
} ();
 






