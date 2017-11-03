 module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    }
  },
  mocha: {
    reporter: 'eth-gas-reporter'
  }
};

/*
module.exports = {
  build: {
    "index.html": "index.html",
    "app.js": [
      "javascripts/app.js"
    ],
    "app.css": [
      "stylesheets/app.css"
    ],
    "images/": "images/"
  },
  rpc: {
    host: "localhost",
    port: 8545
  },
  networks: {
	"staging": {
	  network_id: "*", // custom private network
	  host:"localhost",
	  port: 8545
	},
  }
  mocha: {
    reporter: 'eth-gas-reporter'
  }
};
*/
