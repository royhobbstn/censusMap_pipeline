var StreamConcat = require('stream-concat');
var geojsonStream = require('geojson-stream');
var glob = require('glob');
var fs = require('fs');
var log = require('single-line-log').stderr;
var through2 = require('through2');

var geoParse = geojsonStream.parse();
var geoStringify = geojsonStream.stringify();

const files = fs.readdirSync('./run/splits/divide/header/geojson/');
const prefixes = files.map(d => {
    return d.split('_')[0];
});
const set_prefixes = new Set(prefixes);


set_prefixes.forEach(d => {
    console.log('merging ' + d);


    var w = fs.createWriteStream('./tiles/' + d + '.geojson');

    var results = 0;
    var c = through2({
        objectMode: true
    }, function(result, enc, callback) {
        results++;
        log('Processing result: ' + results);
        this.push(result);
        callback();
    });

    glob('./run/splits/divide/header/geojson/' + d + '_*.geojson', function(er, files) {
        var streams = files.map(file => {
            return fs.createReadStream(file);
        });
        var streamIndex = 0;
        var nextStream = function() {
            if (streamIndex === streams.length) {
                return null;
            }
            return streams[streamIndex++];
        };

        var combinedStream = new StreamConcat(nextStream, {
            objectMode: true
        });

        combinedStream.pipe(geoParse).pipe(c).pipe(geoStringify).pipe(w);
    });

});
