 module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8546,
      network_id: "*" // Match any network id
    }
  },
    ropsten: {
      host: "localhost",
      port: 8545,
      gas: 7000000,
      before_timeout: 1000000, 
      test_timeout: 1000000, 
      network_id: "*",
      from: '0x060bbae03EF52F1B47db247215Da0FB87FF4B2EB'
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
