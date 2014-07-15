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
        $("#uiLayout").html(NanoTemplate.parse('layout', data)); // render the 'mail' template to the #mainTemplate div
        $("#uiContent").html(NanoTemplate.parse('main', data)); // render the 'mail' template to the #mainTemplate div
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


