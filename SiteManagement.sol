pragma solidity ^0.4.0-^0.5.6;
contract SiteManagement {

	// a data sturcture is used to save each saved site's information.
	struct Site {
		address owner;
		address addr;
		uint    timestamp;
		bytes32 description;
	}
	
	// number of current saved sites.
	uint public numSites;
	
	// mapping sturcture (Key -> Site sturcture); regSites for registered site(s); unregSites for unregistered site(s)
	mapping (bytes32 => Site) regSites;
	mapping (bytes32 => Site) unregSites;
	
	// contract initialization.
	constructor() public {
		numSites = 0;
	}
	
	/* registerSite is a function write a VerifiedSite contract address and informations to global regSite
	   input _fqdn: sites fully qualified domain name.
		 _addr: sites VerifiedSite contract address.
		 _description: information given by function user.
	   output bool: ture if function success; false on the contrary.
	*/
	function registerSite(bytes32 _fqdn, address _addr, bytes32 _description) public returns (bool){
		if (regSites[_fqdn].owner == address(0)) {
		    	// create new Site object
			Site storage site = regSites[_fqdn];
			// writing informaion
			site.owner = msg.sender;
			site.addr = _addr;
			site.timestamp = now;
			site.description = _description;
			
			// increase current saved sites
			numSites++;
			return true;
		} else {
			return false;
		}
	}
	/* unregisterSite is a function remove a registered VerifiedSite contract from global regSite,
	                  and dupicate a copy to unregSite for contract users to review.
	   input _fqdn: sites fully qualified domain name that its owner wants to  .
	   output bool: ture if function success; false on the contrary.
	*/
	function unregisterSite(bytes32 _fqdn) public returns (bool) {
		if (regSites[_fqdn].owner == msg.sender) {
		    // dupicate and copy to unregSites
			Site storage site = unregSites[_fqdn];
			site.owner = msg.sender;
			site.addr = regSites[_fqdn].addr;
			site.timestamp = now; // unreg time
			site.description = regSites[_fqdn].description;
			
			// wipe data by _fqdn index
			regSites[_fqdn].owner = address(0);
			regSites[_fqdn].addr = address(0);
			regSites[_fqdn].timestamp = 0;
			regSites[_fqdn].description = 0;
			
			// decrease current saved sites
			numSites--;
			return true;
		} else {
			return false;
		}
	}
	
	/*
	   Getter functions
	*/
	function getSiteAddr(bytes32 _fqdn) view public returns (address) {
		return regSites[_fqdn].addr;
	}
	function getSiteTimestamp(bytes32 _fqdn) view public returns (uint) {
		return regSites[_fqdn].timestamp;
	}
	function getSiteDescription(bytes32 _fqdn) view public returns (bytes32) {
		return regSites[_fqdn].description;
	}
	function getSiteInfo(bytes32 _fqdn) view public returns (address, uint, bytes32) {
	    return (regSites[_fqdn].addr, regSites[_fqdn].timestamp, regSites[_fqdn].description);
	}
}
