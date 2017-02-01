require("../Aion/bin/base.js")();
function server(req, res) {
	let filePath = req.url;
	if (filePath == '/') {
		filePath = '../index.html';
	}else if(filePath.indexOf("log") > 0){
		filePath = '../../' + req.url;
	} else {
		filePath = '../' + req.url;
	}

	let extname = path.extname(filePath);
	let content_type = 'text/html';

	switch (extname) {
		case '.js':
			content_type = 'text/javascript';
			break;
		case '.css':
			content_type = 'text/css';
			break;
	}

	fs.exists(filePath, function(exists) {
		if (exists) {
			fs.readFile(filePath, function(error, content) {
				if (error) {
					res.writeHead(500);
					res.end();
				}
				else {
					res.writeHead(200, { 'Content-Type': content_type });
					res.end(content, 'utf-8');
				}
			});
		}
		else {
			res.writeHead(404);
			res.end();
		}
	});
};
module.exports = {
	server : server
};
