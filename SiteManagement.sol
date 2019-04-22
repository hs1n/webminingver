pragma solidity ^0.4.0-^0.5.6;
contract SiteManagement {

	struct Site {
		address owner;
		address addr;
		uint    timestamp;
		bytes32 description;
	}

	address private creator;
	uint public numSites;
	mapping (bytes32 => Site) regSites;
	mapping (bytes32 => Site) unregSites;
	constructor() public {
		numSites = 0;
		creator = msg.sender;
	}

	function registerSite(bytes32 _fqdn, address _addr, bytes32 _description) public returns (bool){
		if (regSites[_fqdn].owner == address(0)) {
		    // write
			Site storage site = regSites[_fqdn];
			site.owner = msg.sender;
			site.addr = _addr;
			site.timestamp = now;
			site.description = _description;
			
			numSites++;
			return true;
		} else {
			return false;
		}
	}

	function unregisterSite(bytes32 _fqdn) public returns (bool) {
		if (regSites[_fqdn].owner == msg.sender) {
		    // dupicate
			Site storage site = unregSites[_fqdn];
			site.owner = msg.sender;
			site.addr = regSites[_fqdn].addr;
			site.timestamp = now; // unreg time
			site.description = regSites[_fqdn].description;
			
			// wipe
			regSites[_fqdn].owner = address(0);
			regSites[_fqdn].addr = address(0);
			regSites[_fqdn].timestamp = 0;
			regSites[_fqdn].description = 0;
			
			numSites--;
			return true;
		} else {
			return false;
		}
	}

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
