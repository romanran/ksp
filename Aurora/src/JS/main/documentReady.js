_TD.prototype.documentReady = function(){
	this.dom = new dom();
	this.dom.cache();

	new ContactForm(this.dom.$contact);
};

$(function(){
	let TD = new _TD();
	TD.documentReady();
	return window.TD = TD;
});
