var params = {};

window.location.search.split(/[&?]+/).forEach(function(p) {
	var a = p.split("=");
	if (a.length == 2)
		params[a[0]] = a[1];
});

var id = params["id"];
if (id != undefined) {
	loadScript("reports/" + id + ".js").onload = function() {
		if (params["short"] == "true") {
			document.title = "Server Short View Data Report";
			loadScript("js/shortView.js");
		}
		else {
			document.title = "Server Raw Data Report";
			loadScript("js/fullView.js");
		}
	};
}

function loadScript(path) {
	var script = document.createElement("script");
	script.src = path;
	document.body.appendChild(script);
	return script;
}