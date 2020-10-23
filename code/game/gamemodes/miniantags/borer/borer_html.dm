/mob/living/simple_animal/borer/proc/get_html_template(content)
	var/html = {"<!DOCTYPE html">
		<html>
		<meta charset="UTF-8">
		<head>
			<title>Borer Chemicals</title>
			<link rel='stylesheet' type='text/css' href='icons.css'>
			<link rel='stylesheet' type='text/css' href='shared.css'>
			<style type='text/css'>
			body {
				font-size: 12px;
				color: #ffffff;
				font-family: Verdana, Geneva, sans-serif;
				background: #272727;
				overflow-x: hidden;
			}
			a, a:link, a:visited, a:active, .link, .linkOn, .linkOff, .selected, .disabled {
				color: #ffffff;
				text-decoration: none;
				background: #40628a;
				border: 1px solid #161616;
				cursor: pointer;
				display: inline-block;
			}
			a:hover, .linkActive:hover {
				background: #507aac;
				cursor: pointer;
			}
			p {
				text-align: center;
				font-size: 11px;
				margin: 0px;
			}
			table {
				width: 560px;
				text-align: center;
			}
			td {
				width: 560px;
			}
			.chem-select {
				width: 560px;
				text-align: center;
			}
			.enabled {
				background-color: #0a0;
			}
			.disabled {
				background-color: #a00;
			}
			.shown {
				display: block;
			}
			.hidden {
				display: none;
			}
			</style>
			<script src="jquery.min.js"></script>
			<script type='text/javascript'>
				function update_chemicals(chemicals) {
					$('#chemicals').text(chemicals);
				}
				$(function() {
				});
			</script>
		</head>
		<body scroll='yes'><div id='content'>
		[content]
		</div></body></html>"}
	return html
