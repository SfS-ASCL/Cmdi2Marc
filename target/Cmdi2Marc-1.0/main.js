/** @jsx React.DOM */

var Container = React.createClass({displayName: 'Container',
	getInitialState: function() {
		return {status:"info", msg:"", files: {}};
	},
	upload: function(event) {
		var that = this;
		var up = new Uploader("rest/multi");
		up.onSuccess = function() {
			if (this.xhr.status === 200) {
				var json = JSON.parse(this.xhr.response);
				console.log("upload success, ret ok", json, this);
				that.setState( {status:"success", msg:"Success", files: json});
			} else {
				console.log("upload success, ret not ok", this);
				that.setState( {status:"danger", msg: this.xhr.response, files: {}});
			}
		};
		this.setState( {ok:true, msg:"Uploading, please wait...", files: {}});
		up.upload(event);
	},
	render: function() {
		return (
			React.DOM.div({className: "container"}, 
				React.DOM.div({className: "row clearfix"}, 
					React.DOM.div({className: "col-md-12 column"}, 
						React.DOM.div({className: "jumbotron"}, 
							React.DOM.h2(null, "CMDI to MARC 21  transformer (experimental)"), 
							React.DOM.p(null, "This web service allows you to convert a CMDI metadata file to the Marc 21 format.")
						), 
						FileUploadBox({onUpload: this.upload}), 
						StatusBox({status: this.state.status, text: this.state.msg, progress: this.state.progress}), 
						DownloadBox({files: this.state.files}), 
						React.DOM.hr(null), 
						React.DOM.p(null, "You can also use this service programmatically, like this:"), 
						React.DOM.pre(null, "$ curl -d @input.cmdi.xml -o output.marc.xml http://weblicht.sfs.uni-tuebingen.de/converter/Cmdi2Marc/rest"
						),
                                                React.DOM.hr(null), 
						React.DOM.p(null, "© Seminar für Sprachwissenschaft, Universität Tübingen, 2016.")
					)
				)
			)
		);
	}
});

var FileUploadBox = React.createClass({displayName: 'FileUploadBox',
	propTypes: {
		onUpload: React.PropTypes.func.isRequired		
	},
	onUpload: function(event) {
		this.props.onUpload(event);
	},
	render: function() {
		var specialAddon = {marginRight:"10px", border:"none", background:"none"};
		return (
			React.DOM.div({className: "fileUploadBox"}, 
				React.DOM.div({className: "input-group"}, 
					React.DOM.span({style: specialAddon}, 
						"Upload your CMDI files:"
					), 
					React.DOM.span({className: "btn btn-primary btn-file"}, 
						"Browse",  
						React.DOM.input({type: "file", name: "fileUpload", onChange: this.onUpload})
					)
				)
			)
		);
	}
});

var StatusBox = React.createClass({displayName: 'StatusBox',
	propTypes: {
		status: React.PropTypes.string.isRequired,
		text:  React.PropTypes.string.isRequired
	},
	render: function() {
		var style = {marginTop:"10px"};
		var className="alert alert-" + this.props.status;
		if (this.props.text.length === 0) 
			return React.DOM.div(null);		return 	React.DOM.div({className: "statusBox", style: style}, 
					React.DOM.div({className: className, role: "alert"}, this.props.text)
				) ;
	}
});

function iterateMap(map, fn) {
	var i = 0;
	for (var p in map) {
		if (map.hasOwnProperty(p)) {
			fn(i, p, map[p]);
		}
	}
}

var DownloadBox = React.createClass({displayName: 'DownloadBox',
	propTypes: {
		files: React.PropTypes.object.isRequired
	},
	render: function() {
		var files = [];
		iterateMap(this.props.files, function (i, k, v) {
			files.push(React.DOM.li({key: i, className: "list-group-item"}, React.DOM.a({href: v}, k)));
		});
		var header = $.isEmptyObject(files) ? (React.DOM.span(null)) : (React.DOM.p(null, "Download Dublin Core: "));
		return (React.DOM.div(null, " ", header, 
					React.DOM.ul({className: "downloadBox list-group"}, " ", files, " ")
				) );
	}
});

React.renderComponent(Container(null), document.getElementById('main'));

///////////////////////////////////////////////////////////////////////////////

function Uploader(url) {
	var that = this;
	that.url = url;
	this.progress = -1;

	this.cancelUpload = function() {
		if (that.xhr)
			that.xhr.abort();
		that.xhr = null;
		that.progress = -1;
		if (that.onCancel)
			that.onCancel();
	};

	var onUploadProgress = function(e) {
		var done = e.position || e.loaded, total = e.totalSize || e.total;
		var percent = Math.floor( done / total * 1000 ) / 10;
		that.progress = percent;
	};

	this.upload = function(event) {
		var xhr = new XMLHttpRequest();
		xhr.addEventListener('progress', onUploadProgress, false);
		if ( xhr.upload ) {
			xhr.upload.onprogress = onUploadProgress;
		}
		xhr.onreadystatechange = function(e) {
			if ( 4 == e.currentTarget.readyState ) {
				that.progress = -1;
				if (that.onSuccess)
					that.onSuccess();
			}
		};

		xhr.open('post', that.url, true);
		var fd = new FormData();
		var finput = event.target;
		for (var i = 0; i < finput.files.length; ++i) {
			console.log('uploading file ', finput.files[i]);
			fd.append('file'+i, finput.files[i]);
		}
		xhr.send(fd);
		that.xhr = xhr;
	};
}
