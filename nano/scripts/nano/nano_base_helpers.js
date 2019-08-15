// NanoBaseHelpers is where the base template helpers (common to all templates) are stored
NanoBaseHelpers = function ()
{
    var _baseHelpers = {
            // change ui styling to "syndicate mode"
            syndicateMode: function() {
                var syndicateSVG = "url('data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+DQo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgdmVyc2lvbj0iMS4wIiB2aWV3Qm94PSIwIDAgNDAwIDIwMCIgb3BhY2l0eT0iLjI1Ij4NCgk8cG9seWdvbiBwb2ludHM9IjI1MCwwIDE1MCwwIDEwMCw1MCI+PC9wb2x5Z29uPg0KCTxwb2x5Z29uIHBvaW50cz0iMTAwLDUwIDE1MCwyNSAyMDAsNjUgMjUwLDE1MCI+PC9wb2x5Z29uPg0KCTxwb2x5Z29uIHBvaW50cz0iMjUwLDE1MCAyMDAsOTAgMTAwLDIwMCI+PC9wb2x5Z29uPg0KPC9zdmc+')";
                $('.mainBG').css("background", syndicateSVG + " no-repeat fixed center/70% 70%, linear-gradient(to bottom, #8f1414 0%, #4B0A0A 100%) no-repeat fixed center/100% 100%;");

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
            link: function( text, icon, parameters, status, elementClass, elementId ) {
                var iconHtml = '';
                var iconClass = 'noIcon';
                if (typeof icon != 'undefined' && icon)
                {
                    iconHtml = '<div class="uiLinkPendingIcon"></div><i class="fa fa-fw fa-' + icon + '"></i>';
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

                var tid = NanoTransition.allocID(elementIdHtml + "_" + text.toString().replace(/[^a-z0-9_]/gi, "_") + "_" + icon);

                if (typeof status != 'undefined' && status)
                {
                    return '<div unselectable="on" class="link ' + iconClass + ' ' + tid + '" ' + elementIdHtml + '>' + iconHtml + text + '</div><script>$(function() { var newState = {"..class": "' + elementClass + ' ' + status + '"}; var old = NanoTransition.transitionElement("' + tid + '", null, newState, 200); NanoTransition.animateHover("' + tid + '", null, old, newState); });</script>';
                }

                return '<div unselectable="on" class="linkActive ' + iconClass + ' ' + tid + '" data-href="' + NanoUtility.generateHref(parameters) + '" ' + elementIdHtml + '>' + iconHtml + text + '</div><script>$(function() { var newState = {"..class": "' + elementClass + '"}; var old = NanoTransition.transitionElement("' + tid + '", null, newState, 200); NanoTransition.animateHover("' + tid + '", null, old, newState); });</script>';
            },

            xor: function (number,bit) {
                return number ^ bit;
            },

            precisionRound: function (value, places) {
                if(places == 0){
                    return Math.round(number);
                }
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
            capitalizeFirstLetter: function( string ) {
                return string.charAt(0).toUpperCase() + string.slice(1);
            },
            // Display a bar. Used to show health, capacity, etc.
            displayBar: function( value, rangeMin, rangeMax, styleClass, showText ) {

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
                var tid = NanoTransition.allocID(rangeMin + "_" + rangeMax);

                return '<div class="displayBar ' + tid + ' ' + styleClass + '"><div class="displayBarFill"></div><div class="displayBarText ' + styleClass + '">' + showText + '</div></div><script>$(function() { NanoTransition.transitionElement("' + tid + '", ".displayBarFill", {width: "' + percentage + '%", "..class": "' + styleClass + '"}); });</script>';
            },
            // Convert danger level to class (for the air alarm)
            dangerToClass: function(level) {
                if(level == 0) return 'good';
                if(level == 1) return 'average';
                return 'bad';
            },
            dangerToSpan: function(level) {
                if(level == 0) return '"<span class="good">Good</span>"';
                if(level == 1) return '"<span class="average">Minor Alert</span>"';
                return '"<span class="bad">Major Alert</span>"';
            },
            generateHref: function (parameters) {
                var body = $('body'); // For some fucking reason, data is stored in the body tag.
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
                for (var index in characters) {
                    if (!characters.hasOwnProperty(index) || typeof characters[index] === 'object')
                    {
                        continue;
                    }

                    var parameters;
                    if (paramKey.toUpperCase() == 'UI'){
                        parameters = { 'selectUIBlock' : block, 'selectUISubblock' : subblock };
                    } else {
                        parameters = { 'selectSEBlock' : block, 'selectSESubblock' : subblock };
                    }

                    var status = 'linkActive';
                    if (block == selectedBlock && subblock == selectedSubblock) {
                        status = 'selected';
                    }

                    html += '<div class="link ' + status + ' dnaSubBlock" data-href="' + NanoUtility.generateHref(parameters) + '" id="dnaBlock' + index + '">' + characters[index] + '</div>';

                    index++;
                    if (index % blockSize == 0 && index < characters.length) {
                        block++;
                        subblock = 1;
                        html += '</div><div class="dnaBlock"><div class="link dnaBlockNumber">' + block + '</div>';
                    } else {
                        subblock++;
                    }
                }

                html += '</div>';

                return html;
            },
            cMirror: function(textbox) {
                var editor = CodeMirror.fromTextArea(document.getElementById(textbox), {
                    lineNumbers: true,
                    indentUnit: 4,
                    indentWithTabs: true,
                    theme: "lesser-dark"
                });
            },
            smoothNumber: function(number) {
                var tid = NanoTransition.allocID("n");

                return '<span class="' + tid + '"></span><script>$(function() { var newState = {value: ' + number + '}; var old = NanoTransition.updateElement("' + tid + '", newState); NanoTransition.animateTextValue("' + tid + '", null, -1, old["value"], newState["value"]); });</script>';
            },
            smoothRound: function(number, places) {
                var tid = NanoTransition.allocID(places);
                if(places === undefined)
                    placed = 0;

                return '<span class="' + tid + '"></span><script>$(function() { var newState = {value: ' + number.toFixed(places) + '}; var old = NanoTransition.updateElement("' + tid + '", newState); NanoTransition.animateTextValue("' + tid + '", null, ' + places + ', old["value"], newState["value"]); });</script>';
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
}();
