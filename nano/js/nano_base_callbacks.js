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

			$('.linkActive').off('click');
			$('.linkActive').on('click', function (event) {
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
 






