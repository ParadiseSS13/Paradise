NanoTransition = function() {
	var idCache = {};
	var stateCache = {};
	var currentID = 0;

	NanoStateManager.addBeforeUpdateCallback("TransitionReset", function(updateData) {
		currentID = 0;
		return updateData;
	});

	// get a transition handle, add this to your element's class
	var _allocID = function() {
		return "transition__" + (currentID++);
	}

	// setup transitions, call this exactly once a refresh, returns old state
	var _updateElement = function(id, newState) {
		var cache = idCache[id];
		var oldState;

		var element = document.getElementsByClassName(id);
		if(element.length == 0)
			return newState;

		// verify that the id still points to the same thing
		// and get old state
		element = element[0];
		if(cache
			&& cache.tagName == element.tagName
			&& cache.tabIndex == element.tabIndex
			&& cache.parent == element.parentNode.tagName
			&& cache.children == element.children.length) {

			// yep, this is continuation of old object
			oldState = stateCache[id];
		} else {
			// nop!
			oldState = newState;

			idCache[id] = {
				tagName: element.tagName,
				tabIndex: element.tabIndex,
				parent: element.parentNode.tagName,
				children: element.children.length
			};
		}

		// save new state for next cycle
		stateCache[id] = newState;
		return oldState;
	}

	// animate a state change
	var _animateElement = function(id, filter, oldState, newState) {
		var element = $("." + id);
		if(element.length == 0)
			return;

		var target = filter ? $(element).children(filter) : $(element);

		//  do the animation
		target
			.css(oldState)
			.animate(newState, {
				duration: 2000,
				easing: "swing",
				queue: false,
			});

		// maybe class too?
		var oldClass = oldState["..class"];
		var newClass = newState["..class"];
		if(oldClass && newClass) {
			target.addClass(oldClass);
			if(oldClass != newClass)
				target.switchClass(oldClass, newClass, {
					duration: 1900,
					easing: "swing",
					queue: false
				});
		}
	}

	// helper for most common use
	var _transitionElement = function(id, filter, state) {
		var old = _updateElement(id, state);
		_animateElement(id, filter, old, state);
	}

	return {
		allocID: _allocID,
		updateElement: _updateElement,
		animateElement: _animateElement,
		transitionElement: _transitionElement
	};
}();
