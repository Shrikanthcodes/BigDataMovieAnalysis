'use strict';
const http = require('http');
var assert = require('assert');
const express= require('express');
const app = express();
const mustache = require('mustache');
const filesystem = require('fs');
const url = require('url');
const port = Number(process.argv[2]);
const BASE_URL = "https://api.themoviedb.org/3/";
const API_KEY = "api_key=8bd76990a9c98262f4c7f183e207a4ae";
let SEARCH_URL = BASE_URL + "search/movie?" + API_KEY + "&sort_by=popularity.desc&query=";
const hbase = require('hbase')
var hclient = hbase({ host: process.argv[3], port: Number(process.argv[4]), encoding: 'latin1'})

function rowToMap(row) {
	var stats = {}
	row.forEach(function (item) {
		stats[item['column']] = item['$']
	});
	return stats;
}

function counterToNumber(c) {
	return Number(Buffer.from(c, 'latin1').readBigInt64BE());
}


app.use(express.static('public'));

app.get('/movies.html',function (req, res) {
	const title = req.query['title'];
	console.log(title);

	hclient.table('shrikanth_movie').row(title).get(function (err, cells) {
		const MovieData = rowToMap(cells);
		const movie_year = MovieData['movie:year'];
		const movie_genre = MovieData['movie:genre'];
		let movie_director = MovieData['movie:director'];
		let movie_writer = MovieData['movie:writer'];
		let movie_ratings = counterToNumber(cells[2]['$']);
		let movie_votes = counterToNumber(cells[3]['$']);
		
		function average_rating(cells) {
			if(movie_votes == 0)
				return 0;
			return (movie_ratings/movie_votes).toFixed(1); /* One decimal place */
		}

		hclient.table('shrikanth_recs').row(movie_genre).get(function (err, cells) {
			const GenreRecs = rowToMap(cells);
			let recs_title = GenreRecs['recs:title'];
			let recs_year = GenreRecs['recs:year'];
			let recs_rating = GenreRecs['recs:rating'];
			let recs_director = GenreRecs['recs:director'];
			let recs_writer = GenreRecs['recs:writer'];
			let recs_votes = GenreRecs['recs:votes'];
			let recs_rank = GenreRecs['recs:rank'];
			

		hclient.table('shrikanth_movie_year').row(movie_year).get(function (err, cells) {
			const YearRecs = rowToMap(cells);
			let yrecs_title = YearRecs['movie_year:title'];
			let yrecs_genre = YearRecs['movie_year:genre'];
			let yrecs_rating = YearRecs['movie_year:rating'];
			let yrecs_rank = YearRecs['movie_year:rank'];
			let yrecs_director = YearRecs['movie_year:director'];
			let yrecs_writer = YearRecs['movie_year:writer'];
			let yrecs_votes = YearRecs['movie_year:votes'];


				let template = filesystem.readFileSync("result.mustache").toString();
				let html = mustache.render(template, {
					title: req.query['title'],
					year: movie_year,
					genre: movie_genre,
					avg_rating: average_rating(MovieData),
					votes: movie_votes,
					director: movie_director,
					writer: movie_writer,
					GRec_title: recs_title,
					GRec_year: recs_year,
					GRec_rating: recs_rating,
					GRec_votes: recs_votes,
					GRec_rank: recs_rank,
					GRec_director: recs_director,
					GRec_writer: recs_writer,
					YRec_title: yrecs_title,
					YRec_genre: yrecs_genre,
					YRec_rating: yrecs_rating,
					YRec_rank: yrecs_rank,
					YRec_director: yrecs_director,
					YRec_writer: yrecs_writer,
					YRec_votes: yrecs_votes,
				});
				res.send(html);
			});
		});
	});
});

/* Send simulated weather to kafka */
var kafka = require('kafka-node');
var Producer = kafka.Producer;
var KeyedMessage = kafka.KeyedMessage;
var kafkaClient = new kafka.KafkaClient({kafkaHost: process.argv[5]});
var kafkaProducer = new Producer(kafkaClient);

app.get('/rating.html',function (req, res) {
	var title_val = req.query['title'];
	var rating_val = req.query['rating'];

	var report = {
		title : title_val,
		rating : rating_val
	};

	console.log(report)

	kafkaProducer.send([{ topic: 'shrikanth_movie', messages: JSON.stringify(report)}],
		function (err, data) {
			console.log(err);
			console.log(report);
			res.redirect('submit-rating.html');
		});
});

app.listen(port);
