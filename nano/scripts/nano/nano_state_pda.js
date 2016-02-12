NanoStatePDAClass.inheritsFrom(NanoStateClass);
var NanoStatePDA = new NanoStatePDAClass();
var pda_app_template = null;

function NanoStatePDAClass() {
    this.key = 'pda';
    this.key = this.key.toLowerCase();

    NanoStateManager.addState(this);
}
	
NanoStatePDAClass.prototype.onUpdate = function(data) {
	NanoStateClass.prototype.onUpdate.call(this, data);
	
	try {
		if(data['data']['app'] != null) {
			var template = data['data']['app']['template'];
			if(template != null && template != pda_app_template) {
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
						pda_app_template = template;
						
						if(data['config']['status'] == 2) {
							$('#uiApp .linkActive').addClass('linkPending');
							$('#uiApp .linkActive').oneTime(300, 'linkPending', function () {
								$('#uiApp .linkActive').removeClass('linkPending inactive');
							});
						}
					} catch(error) {
						reportError('ERROR: An error occurred while loading the UI: ' + error.message);
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
		reportError('ERROR: An error occurred while rendering the UI: ' + error.message);
		return;
	}
}