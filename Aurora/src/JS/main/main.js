class _TD {
	//	console.log("If this error: \"www-embed-player.js:628 cast_sender.js net::ERR_\" appears here, it's normal. visit: http://stackoverflow.com/questions/25814914/chrome-youtube-cast-sender-js-console-error for the explanation.");
	constructor() {
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
	}
};

//-- Service
(function () {
	function platform() {
		this.isMobile = {
			Android: function () {
				return navigator.userAgent.match(/Android/i);
			},
			BlackBerry: function () {
				return navigator.userAgent.match(/BlackBerry/i);
			},
			iOS: function () {
				return navigator.userAgent.match(/iPhone|iPad|iPod/i);
			},
			Opera: function () {
				return navigator.userAgent.match(/Opera Mini/i);
			},
			Windows: function () {
				return navigator.userAgent.match(/IEMobile/i);
			}
		};
		var _p = this;
		this.isMobile.rest = function () {
			return (_p.isMobile.BlackBerry() || _p.isMobile.Opera() || _p.isMobile.Windows()) || false;
		};
		if (this.isMobile.rest() || this.isMobile.iOS() || this.isMobile.Android()) {
			return true;
		} else {
			return false;
		}
	}

	function deb(s) {
		if (window.location.hostname == "localhost" || window.location.href.indexOf("dev")>0) {
			console.log(s);
		}
	}

	return window.deb = deb;
})();