"use strict";
/*
NTSL mode

I mostly used the LUA mode from CodeMirror to learn how to do this so credits to the author of that (oh and all the code I copy pasted).
*/
(
CodeMirror.defineMode("NTSL", function(config, parserConfig)
{
	function wordRegEx(words)
	{
		return new RegExp("^(?:" + words.join("|") + ")$", "i");
	}

	function opRegEx(operators)
	{
		return new RegExp("[" + operators.join() + "]", "i");
	}
	var keywords = wordRegEx
	(
		[
			// If and the related.
			"if", "else", "elseif",

			// Function related.
			"def", "return",

			// Loop related.
			"while", "break", "continue",

			"vector", "at",

			"signal", "broadcast", "mem"
		]
	);

	var variables = wordRegEx
	(
		[
			// Couple math constants.
			"PI", "E", "SQURT2",

			// Booleans.
			"FALSE", "TRUE",

			// Directions, why are these in NTSL anyways?
			"NORTH", "SOUTH", "EAST", "WEST",

			// Default frequencies.
			"\\$common", "\\$science", "\\$command", "\\$medical", "\\$engineering", "\\$security", "\\$supply",

			// TCS vars.
			"\\$source", "\\$content", "\\$freq", "\\$pass", "\\$job"
		]
	)

	var operators = opRegEx
	(
		[
			"+", "\\-", "\\/", "*", ",", "(", ")", "{", "}", ";", "=", "|", "&", "~", "^", "!", "%", "<", ">"
		]
	)
	return { // Fuck you too ECMA Script.
		startState: function()
		{
			return { // These carriage returns are 100% a conspiracy.
				comment: false,
				escaped: false,
				string: false
			};
		},

		token: function(stream, state)
		{
			if(stream.eatSpace()) // Skip whitespace.
			{
				return null;
			}

			var char = stream.next();

			if(char == "\\") // Escape it.
			{
				state.escaped = true;
				return "escaped"
			}

			if(state.escaped)
			{
				state.escaped = false;
				return "escaped";
			}

			if(char == "\"")
			{
				if(!state.string && stream.eol())
				{
					return "string"	
				}
				state.string = !state.string;
				return "string";
			}

			if(state.string)
			{
				if(stream.eol())
				{
					state.string = false; // Strings do not last multiple lines.
				}
				return "string";	
			}

			// Comment handling.
			if(state.comment) // We're in a multi-line comment.
			{
				if(char == "*" && stream.eat("/")) // End the comment.
				{
					state.comment = false;
				}
				return "comment";
			}

			if(char == "/") // Potential comment.
			{
				if(stream.eat("/")) // One line comment.
				{
					stream.skipToEnd();
					return "comment";
				}
				else if(stream.eat("*")) // Multi-line.
				{
					state.comment = true;
					return "comment";
				}
			}

			// Attempt to process numbers
			if(/\d/.test(char))
			{
				stream.eatWhile(/[\d.]/);
				return "number";
			}
			
			// Attemp to process keywords.
			else if(/[\w_\$]/.test(char))
			{
				
				stream.eatWhile(/[\w_\$]/);
				if(keywords.test(stream.current()))
				{
					return "keyword";	
				}
				else if(variables.test(stream.current()))
				{
					return "variable";	
				}
			}

			// Attemp to process operators.
			else if(operators.test(char))
			{
				return "operator";	
			}
			
			return null;
		}
		
	};
}
)
)