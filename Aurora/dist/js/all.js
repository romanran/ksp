"use strict";

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var _TD =
//	console.log("If this error: \"www-embed-player.js:628 cast_sender.js net::ERR_\" appears here, it's normal. visit: http://stackoverflow.com/questions/25814914/chrome-youtube-cast-sender-js-console-error for the explanation.");
function _TD() {
	_classCallCheck(this, _TD);

	this.is_local = window.location.hostname == "localhost" ? true : false;
	this.breakpoints = {
		full_hd: 1920 - 1,
		tablet: 1200 - 1,
		large: 1024 - 1,
		archaic: 992 - 1,
		smart: 768 - 1,
		phone: 465 - 1,
		phones: 420 - 1,
		phonexs: 375 - 1
	};
	this.dom_loaded = false;
	this.regx = {
		email: new RegExp("^[a-z0-9._%+-]+@[a-z0-9.-]+.[a-z]{2,4}$")
	};
};

;

//-- Service
(function () {
	function platform() {
		this.isMobile = {
			Android: function Android() {
				return navigator.userAgent.match(/Android/i);
			},
			BlackBerry: function BlackBerry() {
				return navigator.userAgent.match(/BlackBerry/i);
			},
			iOS: function iOS() {
				return navigator.userAgent.match(/iPhone|iPad|iPod/i);
			},
			Opera: function Opera() {
				return navigator.userAgent.match(/Opera Mini/i);
			},
			Windows: function Windows() {
				return navigator.userAgent.match(/IEMobile/i);
			}
		};
		var _p = this;
		this.isMobile.rest = function () {
			return _p.isMobile.BlackBerry() || _p.isMobile.Opera() || _p.isMobile.Windows() || false;
		};
		if (this.isMobile.rest() || this.isMobile.iOS() || this.isMobile.Android()) {
			return true;
		} else {
			return false;
		}
	}

	function deb(s) {
		if (window.location.hostname == "localhost" || window.location.href.indexOf("dev") > 0) {
			console.log(s);
		}
	}

	return window.deb = deb;
})();'use strict';

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var dom = function () {
	function dom() {
		_classCallCheck(this, dom);
	}

	_createClass(dom, [{
		key: 'cache',
		value: function cache() {
			var els = this.getElements();
			_.each(els, this.append.bind(this));
		}
	}, {
		key: 'append',
		value: function append(val, key) {
			var _this = this;

			if (this['$' + key] === undefined) {
				this['$' + key] = $(val.selector);
			}
			if (val.children) {
				_.each(val.children, function (val, key) {
					if (_this['$' + key] === undefined) {
						_this['$' + key] = $(val);
					}
				});
			}
		}
	}, {
		key: 'getElements',
		value: function getElements() {
			var elements = {
				graph: {
					selector: "[graph]"
				}
			};
			return elements;
		}
	}]);

	return dom;
}();"use strict";

_TD.prototype.documentReady = function () {
	this.dom = new dom();
	this.dom.cache();

	this.journal1 = new Journal("journal_Sat-1.json");
	deb(this.journal1);
};

$(function () {
	var TD = new _TD();
	TD.documentReady();
	return window.TD = TD;
});"use strict";

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Journal = function () {
	function Journal(path) {
		_classCallCheck(this, Journal);

		this.readJSON(path);
		this.entries = [];
	}

	_createClass(Journal, [{
		key: "write",
		value: function write() {}
	}, {
		key: "readJSON",
		value: function readJSON(path) {
			$.getJSON("flightlogs/" + path, this.parseJSON.bind(this));
		}
	}, {
		key: "parseJSON",
		value: function parseJSON(data) {
			var _this = this;

			var filtered_data = _.filter(data.entries, function (item, i) {
				return i % 2 == 1;
			});
			_.each(filtered_data, function (item, i) {
				if (i % 2) {
					if (item.entries) {
						_this.crawlObject(item.entries, false);
					}
				}
			});
		}
	}, {
		key: "crawlObject",
		value: function crawlObject(src_obj, nested) {
			var _this2 = this;

			var obj = {};
			//		deb(src_obj);
			_.each(src_obj, function (item, i) {
				if (i % 2) {
					if (item.entries) {
						obj[src_obj[i - 1]] = _this2.crawlObject(item.entries, true);
					} else {
						obj[src_obj[i - 1]] = item;
					}
				}
			});
			if (nested) {
				return obj;
			} else {
				this.entries.push(obj);
			}
		}
	}]);

	return Journal;
}();