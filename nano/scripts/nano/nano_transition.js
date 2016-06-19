NanoTransition = function() {
	var idCache = {};
	var stateCache = {};
	var currentID = 0;

	NanoStateManager.addBeforeUpdateCallback("TransitionReset", function(updateData) {
		currentID = 0;
		return updateData;
	});

	// get a transition handle, add this to your element's class
	var _allocID = function(uniqueID) {
		if(uniqueID == "_Hide_Map_close") // hack because nano does weird thing on first tick
			return "transition__map";

		if(uniqueID === undefined)
			uniqueID = "";
		return "transition__" + (currentID++) + "_" + uniqueID.toString();
	}

	// setup transitions, call this exactly once a refresh, returns old state
	var _updateElement = function(id, newState, merge) {
		var cache = idCache[id];
		var oldState;

		if(merge === undefined)
			merge = false;

		var element = $("." + id);
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

			if(merge) {
				var newStateCopy = {};
				for(k in oldState)
					newStateCopy[k] = oldState[k];
				for(k in newState)
					newStateCopy[k] = newState[k];
				newState = newStateCopy;
			}
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

	var _resolveTarget = function(id, filter) {
		var element = $("." + id);

		return filter ? $(element).children(filter) : $(element);
	}

	// animate a state change
	var _animateElement = function(id, filter, oldState, newState, time) {
		var target = _resolveTarget(id, filter);

		if(time === undefined)
			time = 1900;

		//  do the animation
		target
			.css(oldState)
			.animate(newState, {
				duration: time,
				queue: false
			});

		// maybe class too?
		var oldClass = oldState["..class"];
		var newClass = newState["..class"];
		if(oldClass && newClass) {
			target.addClass(oldClass);
			if(oldClass != newClass) {
				// strip classes that are in both
				var oldClass = oldClass.split(" ");
				var newClass = newClass.split(" ");

				var filteredOldClass = oldClass.filter(function(x) { return newClass.indexOf(x) == -1; });
				var filteredNewClass = newClass.filter(function(x) { return oldClass.indexOf(x) == -1; });

				oldClass = filteredOldClass.join(" ");
				newClass = filteredNewClass.join(" ");

				target.switchClass(oldClass, newClass, {
					duration: time,
					queue: false
				});
			}
		}
	}

	var _animateTextValue = function(id, filter, places, oldValue, newValue, time) {
		var target = _resolveTarget(id, filter);

		if(time === undefined)
			time = 1900;

		if(places == -1)
			target.text(oldValue.toString());//oldValue.toString());
		else
			target.text(oldValue.toFixed(places));//oldValue.toFixed(places));

		if(oldValue != newValue)
			target.animate({i: 1}, {
				duration: time,
				queue: false,
				step: function(now, fx) {
					if(places == -1) {
						fx.elem.textContent = (oldValue * (1 - now) + newValue * now).toString();
					} else {
						fx.elem.textContent = (oldValue * (1 - now) + newValue * now).toFixed(places);
					}
				}
			});
	}

	var _animateHover = function(id, filter, oldState, newState, time) {
		var target = _resolveTarget(id, filter);

		if(time === undefined)
			time = 200;

		if(oldState["..hover"])
			target.addClass("hover");

		target.hover(
			function() {
				target.stop(1, 1).addClass("hover", {
					duration: time,
					queue: false
				});
				_updateElement(id, {"..hover": true}, true);
			},
			function() {
				target.stop(1, 1).removeClass("hover", {
					duration: time,
					queue: false
				});
				_updateElement(id, {"..hover": false}, true);
			}
		);
	}

	// helper for most common use
	var _transitionElement = function(id, filter, state, time) {
		var old = _updateElement(id, state);
		_animateElement(id, filter, old, state, time);
		return old;
	}

	return {
		allocID: _allocID,
		updateElement: _updateElement,
		animateElement: _animateElement,
		animateTextValue: _animateTextValue,
		animateHover: _animateHover,
		transitionElement: _transitionElement
	};
}();
