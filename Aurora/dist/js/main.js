(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
"use strict";

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Journal = function () {
	function Journal(path) {
		_classCallCheck(this, Journal);

		this.readJSON(path);
		this.entries = [];
		this.q = $.Deferred();
	}

	_createClass(Journal, [{
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
				if (item.entries) {
					_this.crawlObject(item.entries, false);
				}
			});
			this.q.resolve();
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
	}, {
		key: "getData",
		get: function get() {
			return this.entries;
		}
	}]);

	return Journal;
}();

},{}],2:[function(require,module,exports){
'use strict';

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var dom = function () {
	function dom($parent) {
		_classCallCheck(this, dom);

		this.$parent = $parent;
	}
	//--cache elements here


	_createClass(dom, [{
		key: 'getElements',
		value: function getElements() {
			return this.elements;
		}
	}, {
		key: 'setElements',
		value: function setElements(elements) {
			if (!_.isEmpty(this.$parent)) {
				elements = {
					parent: {
						selector: "",
						children: elements
					}
				};
			}
			this.elements = elements;
		}

		//caching script

	}, {
		key: 'cache',
		value: function cache(elements) {
			var _this = this;

			if (elements) {
				this.setElements(elements);
			}
			_.each(this.getElements(), function (val, key) {
				_this.append(val, key, _this.$parent);
			});
		}
	}, {
		key: 'append',
		value: function append(val, key, $parent) {
			var _this2 = this;

			if (this['$' + key] === undefined) {
				if (val.hasOwnProperty('selector')) {
					val.selector = this._checkVal(val.selector);
					this._add(val.selector, key, $parent);
				} else {
					val = this._checkVal(val);
					this._add(val, key, $parent);
				}
			}

			if (val.children) {

				_.each(val.children, function (cval, ckey) {

					_this2.append(cval, ckey, _this2['$' + key]);
				});
			}
		}
	}, {
		key: '_add',
		value: function _add(val, key, $parent) {
			this['$' + key] = _.isEmpty($parent) ? $(val) : $parent.find(val);
		}
	}, {
		key: '_checkVal',
		value: function _checkVal(val) {
			return val.indexOf('[') >= 0 ? val.replace('[d-', '[data-') : val;
		}
	}]);

	return dom;
}();

module.exports = dom;

},{}],3:[function(require,module,exports){
'use strict';

Chart.plugins.register({
	beforeDraw: function beforeDraw(chartInstance) {
		var ctx = chartInstance.chart.ctx;
		ctx.fillStyle = "#303439";
		ctx.fillRect(0, 0, chartInstance.chart.width, chartInstance.chart.height);
	}
});

_TD.prototype.documentReady = function () {
	var _this = this;

	var dom = require('./cacheDOM');
	var Journal = require('../layout/Journal');
	this.dom = new dom();
	this.dom.cache();
	this.journals = [];
	$.getJSON("flightlogs/", function (e) {
		deb(e);
	});
	this.journal1 = new Journal(encodeURI('journal_Sat-1 202 311.json'));
	this.journal1.q.then(function () {
		_this.journals.push(_this.journal1);
		_this.createCharts();
	});
};

_TD.prototype.createCharts = function () {
	var _this2 = this;

	//	deb(this.journal1);
	this.journals_A = [];
	_.each(this.journals, function (obj) {
		var $new_canvas = $('<canvas></canvas>');
		_this2.dom.$canvas_wrap.html($new_canvas);
		var journal = new JournalChart($new_canvas, obj);
		deb(journal);
		_this2.journals_A.push(obj);
	});
	var x = [];
};

$(function () {
	window.TD = new _TD();
	TD.documentReady();
});

},{"../layout/Journal":1,"./cacheDOM":2}],4:[function(require,module,exports){
"use strict";

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var _TD =
//	console.log("If this error: \"www-embed-player.js:628 cast_sender.js net::ERR_\" appears here, it's normal. visit: http://stackoverflow.com/questions/25814914/chrome-youtube-cast-sender-js-console-error for the explanation.");
function _TD() {
	_classCallCheck(this, _TD);

	this.is_local = window.location.hostname == "localhost" ? true : false;
	this.breakpoints = {
		full_hd: 1920 - 1,
		desktop: 1440 - 1,
		tablet: 1200 - 1,
		large: 1006 - 1,
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
		if (window.location.hostname == "localhost" || window.location.href.indexOf("dev") > 0 || window.location.href.indexOf(":3000") > 0) {
			console.log.apply(console, arguments);
		}
	}

	window._TD = _TD;
	require('./documentReady');

	return window.deb = deb;
})();

},{"./documentReady":3}]},{},[4]);
