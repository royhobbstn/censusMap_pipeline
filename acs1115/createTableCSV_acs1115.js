'use strict';

var fs = require("fs");

const BigQuery = require('@google-cloud/bigquery');
const Storage = require('@google-cloud/storage');
const request = require('request');
const gcs = Storage();

var datatree;


// load data configuration JSON to get list of table names needed
const getUniqueTableNames = new Promise(function(resolve, reject) {
    request('https://raw.githubusercontent.com/royhobbstn/censusVectorTiles/master/src/json/datatree.js', function(error, response, body) {
        if (error) {
            reject(error);
        }
        fs.writeFile('datatree.js', body, function(err) {
            if (err) {
                reject(err);
            }
            datatree = require('./datatree.js'); // dynamically imported
            let table_names = new Set();
            Object.keys(datatree.acs1115).forEach(key => {
                table_names.add(datatree.acs1115[key].table);
            });
            resolve(table_names);
        });
    });
});

// create storage bucket
const createStorageBucket = new Promise(function(resolve, reject) {
    gcs.createBucket('acs1115_tile_tables', function(err) {
        if (err) {
            // console.log(err);
        }
        // naively assume all is well
        resolve();
    });
});

Promise.all([getUniqueTableNames, createStorageBucket]).then(function(success) {
    console.log(success[0]);

    // Instantiates a client
    const bigquery = BigQuery({
        projectId: 'censusbigquery'
    });

    const unique_tables = success[0];

    unique_tables.forEach(table => {

        const storage = Storage({
            projectId: 'censusbigquery'
        });

        let job;

        bigquery
            .dataset('acs1115tables')
            .table('e' + table.toUpperCase())
            .export(storage.bucket('acs1115_tile_tables').file('e' + table.toUpperCase() + '.csv'))
            .then((results) => {
                job = results[0];
                console.log(`Job ${job.id} started.`);
                return job.promise();
            })
            .then((results) => {
                console.log(`Job ${job.id} completed.`);
            })
            .catch((err) => {
                console.error('ERROR:', err);
            });

    });

});
