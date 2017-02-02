"use strict";

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
	this.journals = [];
	$.getJSON("flightlogs/", function (e) {
		deb(e);
	});
	this.journal1 = new Journal("journal_Sat-1.json");
	this.journal1.q.then(function () {
		_this.journals.push(_this.journal1);
		_this.createCharts();
	});
};

$(function () {
	var TD = new _TD();
	TD.documentReady();
	return window.TD = TD;
});'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

_TD.prototype.createCharts = function () {
	var _this = this;

	//	deb(this.journal1);
	this.journals_A = [];
	_.each(this.journals, function (obj) {
		var $new_canvas = $('<canvas></canvas>');
		_this.dom.$canvas_wrap.html($new_canvas);
		var journal = new JournalChart($new_canvas, obj);
		deb(journal);
		_this.journals_A.push(obj);
	});
	var x = [];
};

var JournalChart = function () {
	function JournalChart($canvas, data) {
		_classCallCheck(this, JournalChart);

		var x = [];
		this.title = data.entries[0].SHIP ? data.entries[0].SHIP : data.entries[0].SPD;
		for (var key in data.entries) {
			if (key == 0) {
				continue;
			}
			x.push(data.entries[key].MISSIONTIME * 1000);
		}
		this.$canvas = $canvas;
		deb(data.entries[0]);
		var opts = this.getType('line', x, _.takeRight(data.entries, data.entries.length - 1));
		this.chart = new Chart($canvas, opts);
	}

	_createClass(JournalChart, [{
		key: 'getType',
		value: function getType(type, labels, data) {
			var _this2 = this;

			var dataset = [];
			var data_arr = [];
			var desc_arr = [];
			var data_l = data.length;
			var ai = 0;
			_.each(data, function (obj, i) {
				var obj_l = Object.keys(obj).length;
				var ni = 0;
				_.each(obj, function (val, key) {
					if ((typeof val === 'undefined' ? 'undefined' : _typeof(val)) == "object") {
						return;
					}
					if (key === "DESC") {
						desc_arr.push(val);
						return 0;
					}
					if (key === "TIME" || key === "MISSIONTIME" || key === "FACING") {
						return 0;
					}
					if (data_arr[key]) {
						data_arr[key].push(val);
					} else {
						data_arr[key] = [];
					}
				});
			});
			var r_colors = random.colors(Object.keys(data_arr).length);
			var ci = 0;
			_.forIn(data_arr, function (arr, key) {
				var _dataset$push;

				dataset.push((_dataset$push = {
					label: key,
					comment: desc_arr,
					fill: false,
					data: arr,
					title: key,
					borderColor: r_colors[ci],
					backgroundColor: r_colors[ci],
					chartColors: r_colors,
					borderWidth: 1,
					radius: 3
				}, _defineProperty(_dataset$push, 'borderWidth', 1), _defineProperty(_dataset$push, 'tension', 0.3), _dataset$push));
				ci++;
			});

			return {
				type: type,
				data: {
					labels: labels,
					datasets: dataset
				},
				backgroundColor: "red",
				options: {
					title: {
						display: true,
						fontColor: 'white',
						fontSize: 20,
						text: this.title
					},
					hover: {
						onHover: function onHover(e) {
							_this2.$canvas.css("cursor", e[0] ? "pointer" : "default");
						},
						animationDuration: 100
					},
					legend: {
						position: 'left',
						labels: {
							fontColor: 'white',
							fontStyle: 'bold'
						},
						onHover: function onHover(e) {
							_this2.$canvas.css("cursor", e ? "pointer" : "default");
						}
					},
					tooltips: {
						mode: 'index',
						intersect: true,
						yPadding: 10,
						xPadding: 10,
						callbacks: {
							title: function title(tooltipItem, data) {
								var datasetLabel = data.datasets[0].comment[tooltipItem[0].index];
								return data.datasets[0].comment[tooltipItem[0].index];
							}
						}
					},
					animation: {
						duration: 100
					},
					scales: {
						yAxes: [{
							gridLines: {
								color: "rgba(195,235,255,0.15)"
							},
							ticks: {
								fontColor: 'white',
								beginAtZero: true
							},
							scaleLabel: {
								display: true
							}
						}],
						xAxes: [{
							gridLines: {
								color: "rgba(195,235,255,0.05)"
							},
							type: 'time',
							position: 'bottom',
							ticks: {
								fontColor: 'white',
								beginAtZero: true

							},
							time: {
								unit: 'second',
								unitStepSize: 5,
								displayFormats: {
									second: 'mm:ss'
								}
							},
							scaleLabel: {
								display: true,
								fontColor: 'white',
								labelString: 'MISSION TIME'
							}
						}]
					}
				}
			};
		}
	}]);

	return JournalChart;
}();

;

Chart.plugins.register({
	beforeDraw: function beforeDraw(chartInstance) {
		var ctx = chartInstance.chart.ctx;
		ctx.fillStyle = "#303439";
		ctx.fillRect(0, 0, chartInstance.chart.width, chartInstance.chart.height);
	}
});"use strict";

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
			return "#" + this.intToRGB(hash);
		}
	}]);

	return Tools;
}();