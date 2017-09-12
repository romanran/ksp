Chart.plugins.register({
	beforeDraw: function (chartInstance) {
		var ctx = chartInstance.chart.ctx;
		ctx.fillStyle = "#303439";
		ctx.fillRect(0, 0, chartInstance.chart.width, chartInstance.chart.height);
	}
});

_TD.prototype.documentReady = function(){
	const dom = require('./cacheDOM'); 
	const Journal = require('../layout/Journal'); 
	this.dom = new dom();
	this.dom.cache();
	this.journals = [];
	$.getJSON("flightlogs/", (e)=>{
		deb(e);
	});
	this.journal1 = new Journal(encodeURI('journal_Sat-1 202 311.json'));
	this.journal1.q.then(()=>{
		this.journals.push(this.journal1);
		this.createCharts();
	});
};

_TD.prototype.createCharts = function () {
	//	deb(this.journal1);
	this.journals_A = [];
	_.each(this.journals, (obj) => {
		const $new_canvas = $('<canvas></canvas>');
		this.dom.$canvas_wrap.html($new_canvas);
		const journal = new JournalChart($new_canvas, obj);
		deb(journal);
		this.journals_A.push(obj);
	});
	let x = [];
};

$(function () {
	window.TD = new _TD();
	TD.documentReady();
});
