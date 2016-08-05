NanoStatePDAClass.inheritsFrom(NanoStateClass);
var NanoStatePDA = new NanoStatePDAClass();

function NanoStatePDAClass() {
    this.key = 'pda';
    this.key = this.key.toLowerCase();
	this.current_template = "";

    NanoStateManager.addState(this);
}
	
NanoStatePDAClass.prototype.onUpdate = function(data) {
	NanoStateClass.prototype.onUpdate.call(this, data);
	var state = this;
	
	try {
		if(data['data']['app'] != null) {
			var template = data['data']['app']['template'];
			if(template != null && template != state.current_template) {
				$.when($.ajax({
					url: template + '.tmpl',
					cache: false,
					dataType: 'text'
				}))
				.done(function(templateMarkup) {
					templateMarkup += '<div class="clearBoth"></div>';

					try {
						NanoTemplate.addTemplate('app', templateMarkup);
						NanoTemplate.resetTemplate('app');
						$("#uiApp").html(NanoTemplate.parse('app', data));
						state.current_template = template;
						
						state.onAfterUpdate(data);
					} catch(error) {
						reportError('ERROR: An error occurred while loading the PDA App UI: ' + error.message);
						return;
					}
				})
				.fail( function () {
					reportError('ERROR: Loading template app(' + template + ') failed!');
				});
			} else {
				if (NanoTemplate.templateExists('app')) {
					$("#uiApp").html(NanoTemplate.parse('app', data));
				}
			}
		}
	} catch(error) {
		reportError('ERROR: An error occurred while rendering the PDA App UI: ' + error.message);
		return;
	}
}