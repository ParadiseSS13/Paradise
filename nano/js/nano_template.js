
var NanoTemplate = function () {

    var _templates = {};
    var _compiledTemplates = {};
	
	var _helpers = {};

    var init = function () {
        
    };

    var compileTemplates = function () {

        for (var key in _templates) {
            try {
                _compiledTemplates[key] = doT.template(_templates[key], null, _templates)
            }
            catch (error) {
                alert(error);
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
        parse: function (templateKey, data) {
            if (!_compiledTemplates.hasOwnProperty(templateKey)) {
                if (!_templates.hasOwnProperty(templateKey)) {
                    alert('ERROR: Template "' + templateKey + '" does not exist in _compiledTemplates!');
                    return;
                }
                compileTemplates();
            }
            return _compiledTemplates[templateKey].call(this, data, _helpers);
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
		}
    }
}();
 

