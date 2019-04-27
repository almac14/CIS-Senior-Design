//Generate report time
document.body.onload = addReportTime(reportTime, "report-time");
document.body.onload = addReportComments(comment,"report-comments");

//Generate all of the tables using the addElement function
document.body.onload = addElement(versionData, "version-data", "Applications", noHighlight);
document.body.onload = addElement(driveData, "drive-data", "Drive Space", noHighlight);
document.body.onload = addElement(ipData, "ip-data", "IP Addresses", noHighlight);
document.body.onload = addElement(osData, "os-data", "OS Version", noHighlight);
document.body.onload = addElement(memoryData, "memory-data", "Memory Usage", noHighlight);
document.body.onload = addElement(timeData, "time-data", "Server Time", noHighlight);
document.body.onload = addElement(servicesData, "services-data", "Server Services", noHighlight);

//Add the report time
function addReportTime (data, id) {
	//Div element where the report time will be added
	var div = document.getElementById(id);
	//Create the heading element
	var head = document.createElement("h3");
	//Create the text
	head.appendChild(document.createTextNode("Report generated on:"));
	var par = document.createElement("p");
	par.appendChild(document.createTextNode(data["DateTime"]));
	//Add to DOM
	div.appendChild(head);
	div.appendChild(par);
}

//Add the report time
function addReportComments (data, id) {
	//Div element where the report time will be added
	var div = document.getElementById(id);
	//Create the heading element
	var com = document.createElement("h3");
	//Create the text
	com.appendChild(document.createTextNode("Comments:"));
	var par = document.createElement("p");
	par.appendChild(document.createTextNode(data));
	//Add to DOM
	div.appendChild(com);
	div.appendChild(par);
}
//Add the tables to the web page
function addElement (data, id, heading, func) {
	//Get data keys
	var keys = [];
	console.log(data);
	data.forEach(function(d){
		Object.keys(d).forEach(function(e){
			if(keys.indexOf(e) === -1){
				keys.push(e);
			}
		});
	});
	
	//Create table element
	var table = document.createElement("table");
	//Get the div to add the table into
	var div = document.getElementById(id);
	//Create a table row for the headers
	var tableRow = document.createElement("tr");
	//Add table row into the table
	table.appendChild(tableRow);
	
	//Create table header elements for each key
	keys.forEach(function(d){
		var tableHeader = document.createElement("th");
		var data = document.createTextNode(d);
		tableHeader.appendChild(data);
		tableRow.appendChild(tableHeader);
	});
	
	//Add highlights
	var tableData = func(data, keys);
	
	//Add table data
	tableData.forEach(function(d){
		table.appendChild(d);
	});
	
	//Add header above table
	var header = document.createElement("h2");
	header.appendChild(document.createTextNode(heading));
	
	div.appendChild(header);
	//Add the table into the div
	div.appendChild(table);
}

//Functions added here for toggling the view of each section
//Copy here and add to full view 
function getVersion() {
    var x = document.getElementById("version-data");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
}

function getDrive() {
	var y = document.getElementById("drive-data");
	if (y.style.display == "none") {
		y.style.display = "block";
	} else {
		y.style.display = "none";
	}
}

function getIP() {
	var z = document.getElementById("ip-data");
	if (z.style.display == "none") {
		z.style.display = "block";
	} else {
		z.style.display = "none";
	}
}

function getOS() {
	var w = document.getElementById("os-data");
	if (w.style.display == "none") {
		w.style.display = "block";
	} else {
		w.style.display = "none";
	}
}

function getMemory() {
	var v = document.getElementById("memory-data");
	if (v.style.display == "none") {
		v.style.display = "block";
	} else {
		v.style.display = "none";
	}
}

function getTimes() {
	var u = document.getElementById("time-data");
	if (u.style.display == "none") {
		u.style.display = "block";
	} else {
		u.style.display = "none";
	}
}

function getServices() {
	var t = document.getElementById("services-data");
	if (t.style.display == "none") {
		t.style.display = "block";
	} else {
		t.style.display = "none";
	}
}

///////////////////////////////////////////////////////////////
//This section contains all of the functions for highlighting//
///////////////////////////////////////////////////////////////

function versionHighlight (data, keys) {
	//make an array for the table rows return
	var rows = [];
	//Get each row of the data
	data.forEach(function(d){
		var tableRow = createRow(d, keys);
		//Highlighting comparison
		if(d["Status"] != "OK"){
			tableRow.className = "red-highlight";
		}
		rows.push(tableRow);
	});
	//Return the array of rows
	return rows;
}

function driveHighlight (data, keys) {
	//make an array for the table rows return
	var rows = [];
	//Get each row of the data
	data.forEach(function(d){
		
		var tableRow = createRow(d, keys);
		//Highlighting comparison
		if(+d["FreeGB"] < 5){
			tableRow.className = "red-highlight";
		}
		rows.push(tableRow);
		
	});
	//Return the array of rows
	return rows;
}

function memoryHighlight (data, keys) {
	//make an array for the table rows return
	var rows = [];
	//Get each row of the data
	data.forEach(function(d){
		
		var tableRow = createRow(d, keys);
		//Highlighting comparison
		if(+d["PctFree"] < 5){
			tableRow.className = "red-highlight";
		}
		rows.push(tableRow);
		
	});
	//Return the array of rows
	return rows;
}

function timeHighlight (data, keys) {
	//make an array for the table rows return
	var rows = [];
	var serverData = data[0];
	//Get each row of the data
	data.forEach(function(d){
		
		var tableRow = createRow(d, keys);
		//Highlighting comparison
		if(serverData["StandardTimeZone"] != d["StandardTimeZone"]) {
			tableRow.className = "red-highlight";
		}
		else if(serverData["DaylightTimeZone"] != d["DaylightTimeZone"]) {
			tableRow.className = "red-highlight";
		}
		else if(Math.abs(serverData["UnixTime"] - d["UnixTime"]) > 120) {
			tableRow.className = "red-highlight";
		}
		rows.push(tableRow);
		
	});
		
	//Return the array of rows
	return rows;
}

function servicesHighlight (data, keys) {
	//make an array for the table rows return
	var rows = [];
	//Get each row of the data
	//delete keys["Ignore"];
	data.forEach(function(d){
		var ignore = d["Ignore"];
		//delete d["Ignore"];
		
		var tableRow = createRow(d, keys);
		//Highlighting comparison
		if((d["StartMode"] == "Auto") && (d["State"] == "Stopped") && !ignore){
			tableRow.className = "red-highlight";
		}
		rows.push(tableRow);
	});
	//Return the array of rows
	return rows;
}

function noHighlight (data, keys){
	//make an array for the table rows return
	var rows = [];
	//Get each row of the data
	data.forEach(function(d){
		var tableRow = createRow(d, keys);
		rows.push(tableRow);
	});
	//Return the array of rows
	return rows;
}

function createRow (data, keys) {
	//Make a table row element
	var tableRow = document.createElement("tr");
	//Get each cell of the data
	keys.forEach(function(key){
		//Make a table data element
		var tableData = document.createElement("td");
		//Fill the table data element
		var dataText = document.createTextNode(data[key]);
		//Add text and cells
		tableData.appendChild(dataText);
		tableRow.appendChild(tableData);
	});
	//Return the row
	return tableRow;
}

function createHeader (keys, ignore) {
	var tableRow = document.createElement("tr");
	//Add table row into the table
	table.appendChild(tableRow);
	
	/*
	ignore.forEach(){
		
	};*/
	
	//Create table header elements for each key
	keys.forEach(function(d){
		var tableHeader = document.createElement("th");
		var data = document.createTextNode(d);
		tableHeader.appendChild(data);
		tableRow.appendChild(tableHeader);
	});
	
	return tableRow;
}
