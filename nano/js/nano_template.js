
var NanoTemplate = function () {

    var _templates = {};
    var _compiledTemplates = {};
	
	var _helpers = {};

    var init = function () {
        // We store initialData and templateData in the body tag, it's as good a place as any
		var templateData = $('body').data('templateData');
		
		if (templateData == null)
		{
			alert('Error: Template data did not load correctly.');
		}		
		
		// we count the number of templates for this ui so that we know when they've all been rendered
		var templateCount = 0;
		for (var key in templateData)
		{
			if (templateData.hasOwnProperty(key))
			{
				templateCount++;
			}
		}
		
		if (!templateCount)
		{
			alert('ERROR: No templates listed!');
		}
		
		// load markup for each template and register it
		for (var key in templateData)
		{
			if (!templateData.hasOwnProperty(key))
			{
				continue;
			}
			
			$.when($.ajax({
				url: templateData[key],
				cache: false,
				dataType: 'text'
			}))
				.done(function(templateMarkup) {					
					
					//templateMarkup = templateMarkup.replace(/ +\) *\}\}/g, ')}}');
					
					templateMarkup += '<div class="clearBoth"></div>';
				
					try
					{
						NanoTemplate.addTemplate(key, templateMarkup)
						
						templateCount--;
						
						if (templateCount <= 0)
						{
							$(document).trigger('templatesLoaded');
						}
					}
					catch(error)
					{
						alert('ERROR: An error occurred while loading the UI: ' + error.message);
						return;
					}
				})					
				.fail(function () {
					alert('ERROR: Loading template ' + key + '(' + templateData[key] + ') failed!');
				});;    
		}	
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
 

