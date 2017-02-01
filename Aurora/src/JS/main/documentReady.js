_TD.prototype.documentReady = function(){
	this.dom = new dom();
	this.dom.cache();

	this.journal1 = new Journal("journal_Sat-1.json");
	deb( this.journal1 );
};

$(function(){
	let TD = new _TD();
	TD.documentReady();
	return window.TD = TD;
});
