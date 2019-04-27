document.body.onload = function() {
	
	var table = document.getElementById("report_list");
	
	reports.forEach(function(r) {
		var row = document.createElement("tr");
		
		var data = document.createElement("td");
		var name = document.createTextNode(r + ":");
		data.appendChild(name);
		row.appendChild(data);
		
		data = document.createElement("td");
		var shortLink = document.createElement("a");
		shortLink.text = "Short"
		shortLink.href = "report.html?short=true&id=" + r;
		data.appendChild(shortLink);
		
		row.appendChild(data);
		
		data = document.createElement("td");
		var fullLink = document.createElement("a");
		fullLink.text = "Full"
		fullLink.href = "report.html?short=false&id=" + r;
		data.appendChild(fullLink);
			
		row.appendChild(data);
		
		table.appendChild(row);
	});
};

