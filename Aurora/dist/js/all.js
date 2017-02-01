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
})();"use strict";

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
})();"use strict";

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
}();'use strict';

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
}();'use strict';

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
}();