'use strict';

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var dom = function () {
	function dom() {
		_classCallCheck(this, dom);
	}
	//Cache elements here


	_createClass(dom, [{
		key: 'getElements',
		value: function getElements() {
			var elements = {
				canvas_wrap: {
					selector: "[charts]"
				}
			};
			return elements;
		}
		//--
		//caching script

	}, {
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
				if (val.selector.indexOf('[') >= 0) {
					val.selector = val.selector.replace('[', '[data-');
					this['$' + key] = $(val.selector);
				} else {
					this['$' + key] = $(val.selector);
				}
			}
			if (val.children) {
				_.each(val.children, function (val, key) {
					if (_this['$' + key] === undefined) {
						if (val.indexOf('[') >= 0) {
							val = val.replace('[', '[data-');
							_this['$' + key] = $(val);
						} else {
							_this['$' + key] = $(val);
						}
					}
				});
			}
		}
	}]);

	return dom;
}();"use strict";

_TD.prototype.documentReady = function () {
	var _this = this;

	this.dom = new dom();
	this.dom.cache();
	this.journal1 = new Journal("journal_Sat-1.json");
	this.journal1.q.then(function () {
		_this.createCharts();
	});
};

$(function () {
	var TD = new _TD();
	TD.documentReady();
	return window.TD = TD;
});"use strict";

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

(function () {
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
	return window._TD = _TD;
})();
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

	function deb() {
		if (window.location.hostname == "localhost" || window.location.href.indexOf("dev") > 0) {
			console.log.apply(console, arguments);
		}
	}

	return window.deb = deb;
})();'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

_TD.prototype.createCharts = function () {
	var $new_canvas = $('<canvas></canvas>');
	this.dom.$canvas_wrap.append($new_canvas);
	//	deb(this.journal1);
	var x = [];
	var y1 = [];
	var y2 = [];
	var y3 = [];
	for (var key in this.journal1.entries) {
		if (key == 0) {
			continue;
		}
		x.push(this.journal1.entries[key].MISSIONTIME);
		y1.push(this.journal1.entries[key].ALT);
		y2.push(this.journal1.entries[key].SURV);
		y3.push(this.journal1.entries[key].VERTICALSPEED);
	}
	new Chart($new_canvas, this.getType('bar', x, this.journal1.entries));
};
_TD.prototype.getType = function (type, labels, data) {
	var dataset = [];
	var data_arr = [];
	deb(data.length);
	var data_l = data.length;
	var ai = 0;
	_.each(data, function (obj, i) {
		var ni = 0;
		var obj_l = obj.length;
		_.each(obj, function (val, key) {
			ni++;
			if ((typeof val === 'undefined' ? 'undefined' : _typeof(val)) == "object") {
				return;
			}
			if (data_arr[key]) {
				data_arr[key].push(val);
			} else {
				data_arr[key] = [];ai++;
			}
		});
		if (ni == obj_l) {
			ai++;
			deb("obj end");
		}
		if (ai == data_l) {
			deb("finish end");
		}
	});
	_.each(data_arr, function (arr, key) {
		ai++;
		dataset.push({
			label: key,
			fill: false,
			data: arr,
			borderColor: [Tools.strToColor(key)],
			borderWidth: 1
		});
	});
	//	deb(dataset);
	return 0;
	switch (type) {
		case 'bar':
			return {
				type: 'line',
				data: {
					labels: labels,
					datasets: dataset
				},
				options: {
					scales: {
						yAxes: [{
							ticks: {
								beginAtZero: true
							},
							scaleLabel: {
								display: true,
								labelString: 'ATITUDE'
							}
						}],
						xAxes: [{
							ticks: {
								beginAtZero: true
							},
							scaleLabel: {
								display: true,
								labelString: 'MISSION TIME'
							}
						}]
					}
				}
			};
			break;
	}
};"use strict";

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
}();"use strict";

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Tools = function () {
	function Tools() {
		_classCallCheck(this, Tools);
	}

	_createClass(Tools, null, [{
		key: "hashCode",
		value: function hashCode(str) {
			var hash = 0;
			for (var i = 0; i < str.length; i++) {
				hash = str.charCodeAt(i) + ((hash << 5) - hash);
			}
			return hash;
		}
	}, {
		key: "intToRGB",
		value: function intToRGB(i) {
			var c = (i & 0x00FFFFFF).toString(16).toUpperCase();
			return "00000".substring(0, 6 - c.length) + c;
		}
	}, {
		key: "strToColor",
		value: function strToColor(str) {
			var hash = this.hashCode(str);
			return this.intToRGB(hash);
		}
	}]);

	return Tools;
}();