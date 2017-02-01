_TD.prototype.documentReady = function(){
	this.dom = new dom();
	this.dom.cache();
	this.journals = [];
	$.getJSON("flightlogs/", (e)=>{
		deb(e);
	});
	this.journal1 = new Journal("journal_Sat-1.json");
	this.journal1.q.then(()=>{
		this.journals.push(this.journal1);
		this.createCharts();
	});
};

$(function(){
	let TD = new _TD();
	TD.documentReady();
	return window.TD = TD;
});
