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
            Object.keys(datatree.c2010).forEach(key => {
                table_names.add(datatree.c2010[key].table);
            });
            resolve(table_names);
        });
    });
});

// create storage bucket
const createStorageBucket = new Promise(function(resolve, reject) {
    gcs.createBucket('c2010_tile_tables', function(err) {
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
            .dataset('c2010tables')
            .table(table.toUpperCase())
            .export(storage.bucket('c2010_tile_tables').file(table.toUpperCase() + '_*.csv'))
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
