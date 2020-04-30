pragma solidity ^0.5.17;


contract SiteManagement {
    // a data sturcture is used to save each saved site's information.
    struct Site {
        address owner; // registerSite function performer's ethereum address.
        address addr; // VerifiedSite contract ethereum address.
        uint256 timestamp; // UNIX time format of writing time (block time).
        bytes32 description; // extra information given by user.
    }

    // mapping sturcture (Key -> Site sturcture)
    mapping(bytes32 => Site) regSites; // regSites for registered site(s)
    mapping(bytes32 => Site) unregSites; // unregSites for unregistered site(s)

    // contract initialization.
    constructor() public {}

    /* registerSite is a function that write a VerifiedSite contract address and informations to global regSite
	   input _fqdn: sites fully qualified domain name.
		 _addr: sites VerifiedSite contract address.
		 _description: information given by function user.
	   output bool: ture if function success; false on the contrary.
	*/
    function registerSite(bytes32 _fqdn, address _addr, bytes32 _description)
        public
        returns (bool)
    {
        require(_fqdn > 0, "FQDN input error");
        require(_addr > address(0), "VS addr input error");
        require(_description >= 0, "description error");

        if (regSites[_fqdn].owner == address(0)) {
            // create new Site object
            Site memory site = regSites[_fqdn];
            // writing informaion
            site.owner = msg.sender;
            site.addr = _addr;
            site.timestamp = now;
            site.description = _description;

            return true;
        } else {
            return false;
        }
    }

    /* unregisterSite is a function that remove a registered VerifiedSite contract from global regSite,
	                  and dupicate a copy to unregSite for contract users to review.
	   input _fqdn: sites fully qualified domain name that its owner wants to  .
	   output bool: ture if function success; false on the contrary.
	*/
    function unregisterSite(bytes32 _fqdn) public returns (bool) {
        require(_fqdn > 0, "FQDN input error");
        if (regSites[_fqdn].owner == msg.sender) {
            // dupicate and copy to unregSites
            Site memory site = unregSites[_fqdn];
            site.owner = msg.sender;
            site.addr = regSites[_fqdn].addr;
            site.timestamp = now; // unreg time
            site.description = regSites[_fqdn].description;

            // wipe data by _fqdn index
            regSites[_fqdn].owner = address(0);
            regSites[_fqdn].addr = address(0);
            regSites[_fqdn].timestamp = 0;
            regSites[_fqdn].description = 0;

            return true;
        } else {
            return false;
        }
    }

    /*
	   Getter functions
	*/
    function getSiteAddr(bytes32 _fqdn) public view returns (address) {
        require(_fqdn > 0, "FQDN input error");
        return regSites[_fqdn].addr;
    }

    function getSiteTimestamp(bytes32 _fqdn) public view returns (uint256) {
        require(_fqdn > 0, "FQDN input error");
        return regSites[_fqdn].timestamp;
    }

    function getSiteDescription(bytes32 _fqdn) public view returns (bytes32) {
        require(_fqdn > 0, "FQDN input error");
        return regSites[_fqdn].description;
    }

    function getSiteInfo(bytes32 _fqdn)
        public
        view
        returns (address, uint256, bytes32)
    {
        require(_fqdn > 0, "FQDN input error");
        return (
            regSites[_fqdn].addr,
            regSites[_fqdn].timestamp,
            regSites[_fqdn].description
        );
    }
}
